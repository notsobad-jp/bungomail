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
    official_ch = Channel.find_by(code: "bungomail-official")

    user_attributes = []
    membership_attributes = []
    subscription_attributes = []

    File.open('tmp/google_migration/google_members.txt', 'r') do |f|
      f.each_line do |line|
        email = line.chomp
        p email
        next if email == 'info@notsobad.jp'
        uuid = SecureRandom.uuid
        user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: default_timestamp, activation_state: "active"}
        membership_attributes << {id: uuid, plan: 'free', status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
        subscription_attributes << {user_id: uuid, channel_id: official_ch.id, status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
      end
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
      Subscription.insert_all(subscription_attributes)
    end
  end

  ## (2) 一時停止履歴からいまGoogleに存在するユーザーをインポート（status: paused → 再開ログを予約）
  task import_paused_users: :environment do |_task, _args|
    official_ch = Channel.find_by(code: "bungomail-official")
    csv_rows = CSV.read("tmp/google_migration/paused_logs.csv", headers: true).uniq{|row| row['メールアドレス'] }
    csv_rows.each do |log|
      p log['メールアドレス']
      user = User.find_by(email: log['メールアドレス'])
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      next unless user

      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        user.subscriptions.first.update(status: 'paused', updated_at: timestamp)
        user.subscription_logs.create!(channel_id: official_ch.id, status: 'active', created_at: timestamp, updated_at: timestamp, apply_at: Time.zone.parse("2021/03/01"), google_action: 'update') # 配信再開用のログを予約
      end
    end
  end

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
      user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: timestamp}   # ログインできないように、未activationの状態で登録
      membership_attributes << {id: uuid, plan: 'free', status: 'canceled', created_at: default_timestamp, updated_at: timestamp}
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
        membership_attributes << {id: uuid, plan: 'free', status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
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
    official_ch = Channel.find_by(code: "bungomail-official")

    ChannelSubscriptionLog.all.each do |log|
      case log.action
      when "subscribed"
        user = User.find_by(email: log.email)
        next if !user
        user.update(created_at: log.created_at, updated_at: log.updated_at) if user.created_at == default_timestamp
      when "paused"
        user = User.find_by(email: log.email)
        next if !user || user.subscriptions.blank?
        user.subscriptions.first.update(status: 'paused', updated_at: log.created_at)
        user.subscription_logs.create(channel_id: official_ch.id, status: 'active', apply_at: Time.zone.parse("2021/03/01"), google_action: 'update', created_at: log.created_at, updated_at: log.updated_at)
      when "unsubscribed"
        user = User.find_by(email: log.email)
        next if user

        uuid = SecureRandom.uuid
        user_attributes = []
        membership_attributes = []
        user_attributes << {id: uuid, email: log.email, created_at: default_timestamp, updated_at: log.created_at}
        membership_attributes << {id: uuid, plan: 'free', status: 'canceled', created_at: default_timestamp, updated_at: log.created_at}

        ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
          User.insert_all(user_attributes)
          Membership.insert_all(membership_attributes)
        end
      end
    end
  end
end
