namespace :tmp do
  ## (0) GoogleGroupの現在の登録者をそのままダウンロード
  task download_google_group_members: :environment do |_task, _args|
    service = GoogleDirectoryService.instance
    group_key = ENV['GROUP_KEY']

    member_emails = []
    next_page_token = ""
    loop do
      res = service.list_members(group_key, page_token: next_page_token)
      member_emails << res.members.map(&:email)
      next_page_token = res.next_page_token
      break if next_page_token.blank?
      sleep 1
    end

    file_path = 'tmp/google_migration/google_members.txt'
    # file_path = 'tmp/google_migration/dogramagra.txt'
    File.open(file_path, 'w') do |f|
      member_emails.flatten.uniq.each { |s| f.puts(s) }
    end
  end

  ## (1) DLしたGoogleGroupの現在の登録者をインポート（status: active）
  task import_google_group_members: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2018/4/30")

    user_attributes = []
    membership_attributes = []
    subscription_attributes = []

    File.open('tmp/google_migration/google_members.txt', 'r') do |f|
      f.each_line do |line|
        email = line.chomp
        p email
        next if email == 'info@notsobad.jp'
        uuid = SecureRandom.uuid
        user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: default_timestamp}
        membership_attributes << {id: uuid, plan: 'free', status: Membership.statuses[:active], created_at: default_timestamp, updated_at: default_timestamp}
        subscription_attributes << {user_id: uuid, channel_id: Channel::OFFICIAL_CHANNEL_ID, created_at: default_timestamp, updated_at: default_timestamp}
      end
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
      Subscription.insert_all(subscription_attributes)
    end
  end

  ## (2) 一時停止履歴からいまGoogleに存在するユーザーをインポート（status: paused → 再開ログを予約）
  ## ※現時点の一時停止ユーザーは、2021/3/1に手動でactiveに戻してログは作らない
  # task import_paused_users: :environment do |_task, _args|
  #   official_ch = Channel.find_by(code: "bungomail-official")
  #   csv_rows = CSV.read("tmp/google_migration/paused_logs.csv", headers: true).uniq{|row| row['メールアドレス'] }
  #   csv_rows.each do |log|
  #     p log['メールアドレス']
  #     user = User.find_by(email: log['メールアドレス'])
  #     timestamp = Time.zone.parse(log['タイムスタンプ'])
  #     next unless user
  #
  #     ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
  #       user.subscriptions.first.update(status: 'paused', updated_at: timestamp)
  #       user.subscription_logs.create!(channel_id: official_ch.id, status: 'active', created_at: timestamp, updated_at: timestamp, apply_at: Time.zone.parse("2021/03/01"), google_action: 'update') # 配信再開用のログを予約
  #     end
  #   end
  # end

  ## (3) 解約履歴からいまGoogleにいないユーザーをインポート(status: canceled)
  task import_unsubscribed_users: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2018/4/30")

    user_attributes = []
    membership_attributes = []

    existing_emails = User.pluck(:email)
    csv_rows = CSV.read("tmp/google_migration/unsubscribed_logs.csv", headers: true).uniq{|row| row['メールアドレス'] }
    csv_rows.each do |log|
      p log['メールアドレス']
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      email = log['メールアドレス']
      next if existing_emails.include?(email)

      uuid = SecureRandom.uuid
      user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: timestamp}
      membership_attributes << {id: uuid, plan: 'free', status: Membership.statuses[:canceled], created_at: default_timestamp, updated_at: timestamp}
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
    end
  end

  ## (4) ドグラ・マグラGroupからいまGoogleにいないユーザーをインポート(status: active、 subscriptionはなし)
  task import_dogramagra_users: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2020/01/01")

    user_attributes = []
    membership_attributes = []

    existing_emails = User.pluck(:email)
    File.open('tmp/google_migration/dogramagra.txt', 'r') do |f|
      f.each_line do |line|
        email = line.chomp
        p email
        next if existing_emails.include?(email)

        uuid = SecureRandom.uuid
        user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: default_timestamp, activation_state: "active"}
        membership_attributes << {id: uuid, plan: 'free', status: Membership.statuses[:active], created_at: default_timestamp, updated_at: default_timestamp}
      end
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
    end
  end

  ## (5) 購読履歴からいまGoogleに存在するユーザーの情報を更新（timestampを更新）
  task import_subscribed_users: :environment do |_task, _args|
    existing_emails = User.pluck(:email)
    csv_rows = CSV.read("tmp/google_migration/subscribed_logs.csv", headers: true).uniq{|row| row['メールアドレス'] }
    csv_rows.each do |log|
      p log['メールアドレス']
      next if !existing_emails.include?(log['メールアドレス'])
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      user = User.find_by(email: log['メールアドレス'])

      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        user.update!(created_at: timestamp, updated_at: [user.updated_at, timestamp].max)
        user.membership.update!(created_at: timestamp, updated_at: [user.membership.updated_at, timestamp].max)
        user.subscriptions.first&.update!(created_at: timestamp, updated_at: [user.subscriptions.first&.updated_at, timestamp].max) # 解約ユーザーの場合は存在しないので&ガード
      end
    end
  end

  ## (6) DBに保存されたChannelSubscriptionLogの内容もマージする
  task import_channel_subscription_logs: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2018/4/30")

    ChannelSubscriptionLog.all.each do |log|
      timestamp = log.created_at
      p log.email

      case log.action
      when "subscribed"
        user = User.find_by(email: log.email)
        next if !user
        user.update(created_at: [user.created_at, timestamp].min, updated_at: timestamp)
        user.membership.update!(created_at: [user.membership.created_at, timestamp].min, updated_at: [user.membership.updated_at, timestamp].max)
        user.subscriptions.first&.update!(created_at: [user.subscriptions.first&.created_at, timestamp].min, updated_at: [user.subscriptions.first&.updated_at, timestamp].max) # 解約ユーザーの場合は存在しないので&ガード
      when "paused"
        ## ※現時点の一時停止ユーザーは、2021/3/1に手動でactiveに戻してログは作らない
        # user = User.find_by(email: log.email)
        # next if !user || user.subscriptions.blank?
        # user.subscriptions.first.update(status: 'paused', updated_at: timestamp)
        # user.subscription_logs.create(channel_id: official_ch.id, status: 'active', apply_at: Time.zone.parse("2021/03/01"), google_action: 'update', created_at: timestamp, updated_at: timestamp)
      when "unsubscribed"
        user = User.find_by(email: log.email)
        next if user

        # FIXME: canceledのmembershipを作りたいけど、callbackでactiveにされるのでinsert_allしてる（普通に作ってからupdateでよかったかも）
        uuid = SecureRandom.uuid
        user_attributes = []
        membership_attributes = []
        user_attributes << {id: uuid, email: log.email, created_at: default_timestamp, updated_at: timestamp}
        membership_attributes << {id: uuid, plan: 'free', status: Membership.statuses[:canceled], created_at: default_timestamp, updated_at: timestamp}

        ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
          User.insert_all!(user_attributes)
          Membership.insert_all!(membership_attributes)
        end
      end
    end
  end

  # (7) 一時停止履歴からGoogleGroupのステータスを更新する
  ## 2021.2.28の通常配信後に実行
  task revert_paused_users: :environment do |_task, _args|
    csv_rows = CSV.read("tmp/google_migration/paused_logs.csv", headers: true).uniq{|row| row['メールアドレス'] }
    emails = csv_rows.pluck("メールアドレス")
    emails << ChannelSubscriptionLog.where(action: "paused").pluck(:email)
    emails.flatten.uniq.each do |email|
      p email
      sub = Subscription.includes(:user).find_by(users: { email: email })
      next unless sub

      begin
        service = GoogleDirectoryService.instance
        member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'ALL_MAIL')
        service.update_member("bungomail-text@notsobad.jp", email, member)
        p "restarted!"
      rescue => e
        p e
      end
    end
  end


  task destroy_canceled_users: :environment do |_task, _args|
    # 0. localでrollback
    # 0-1. 本番DBをlocalにリストア
    # 1. 手動でmembershipのplanのnull:falseを解除
    # 2. 解約済みをplan: nilに
    Membership.where(status: 3).update_all(plan: nil)
    # 3. db:migrate（EmailDigestテーブル作成）
    # 4. 全ユーザーのEmailDigest作成(解約者はupdated_atを更新)
    digests = []
    User.each do |user|
      digests << {digest: "", created_at: user.created_at, updated_at: user.membership.plan.nil? ? user.updated_at : user.created_at}
    end
    EmailDigest.insert_all(digests)
    # 5. 解約済みユーザーを削除
    User.includes(:membership).where(membership: {plan: nil}).destroy_all
  end


  task copy_campaigns_to_feeds: :environment do |_task, _args|
    assignments = []
    CampaignGroup.where("start_at > ?", Time.zone.parse("2021-04-01")).each do |cg|
      assignments << {
        channel_id: Channel::OFFICIAL_CHANNEL_ID,
        book_id: cg.book_id,
        book_type: 'AozoraBook',
        start_date: cg.start_at.to_date,
        end_date: cg.start_at.to_date + (cg.count - 1).days,
        created_at: cg.created_at,
        updated_at: cg.updated_at,
      }
    end
    BookAssignment.insert_all(assignments)
    p "Inserted: #{assignments.length}"

    BookAssignment.where("start_date > ?", Time.zone.parse("2021-04-01")).each do |ba|
      res = ba.create_feeds
      p "Created feeds for #{ba.start_date}:"
      p res
    end
  end


  task import_aozora_additional_info: :environment do |_task, _args|
    CSV.foreach('tmp/aozora_books.csv', headers: true) do |fg|
      next if fg["役割フラグ"] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）
      book = AozoraBook.find_by(id: fg[0].to_i)
      next unless book

      source = "「#{fg['底本名1']}」#{fg['底本出版社名1']}"
      source += ", #{fg['底本初版発行年1']}" if fg['底本初版発行年1'].present?
      book.update!(
        source: source,
      ) if fg['底本名1'].present?

      puts "[Updated] #{book.title}"
    end
  end

  task create_subscription_for_paid_users: :environment do |_task, _args|
    channel = Channel.find_by(code: 'bungomail-official')
    User.where.not(stripe_customer_id: nil).each do |user|
      user.subscriptions.create(channel_id: channel.id)
    end
  end
end
