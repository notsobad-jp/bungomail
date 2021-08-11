namespace :cron do
  # [月初] Stripe登録状況とSubscriptionを一致させる
  task sync_stripe_subscription: :environment do |_task, _args|
    emails = []
    has_more = true
    last_id = nil

    # Stripe支払い中のuser一覧取得
    while has_more do
      list = Stripe::Subscription.list({limit: 100, starting_after: last_id, expand: ['data.customer']})
      last_id = list.data.last&.id
      has_more = list.has_more
      emails += list.data.map{|m| m.customer.email}
    end

    # 解約した人のstatus更新
    unsubs = User.where.not(email: emails).where(paid_member: true)
    unsubs.update_all(paid_member: false)
    p "UnSubscribed users: #{unsubs.length}"

    # 支払い中の人のstatus更新
    users = User.where(email: emails)
    users.update_all(paid_member: true)
    p "Subscribing users: #{user.length}"

    # 月初時点で有料の人はトライアル体験済みにする
    digests = users.map{|u| Digest::SHA256.hexdigest(u.email) }
    EmailDigest.where(digest: digests).update_all(trial_ended: true)

    # 有料じゃないユーザーのsubscriptionは全部削除
    free_channel_ids = [Channel.find_by(code: 'long-novel')]
    Subscription.where.not(user_id: users.pluck(:id)).where.not(channel_id: free_channel_ids).delete_all

    # 有料ユーザーは全員公式チャネルを購読
    ## TODO: 有料でも公式チャネルの購読on/offしたい
    records = []
    users.pluck(:id).each do |user_id|
      records << { user_id: user_id, channel_id: Channel.find_by(code: 'bungomail-official').id }
    end
    Subscription.upsert_all(records, unique_by: %i[user_id channel_id])
    p "Total sub: #{Subscription.all.count}"
  end

  # [Daily?] 決済画面遷移時に作成されるcustomerのうち、決済情報を登録せずに離脱したemailなしcustomerを定期的に削除する
  task clean_stripe_blank_accounts: :environment do |_task, _args|
    has_more = true
    last_id = nil
    emails = []

    # customersの一覧取得
    while has_more do
      list = Stripe::Customer.list({limit: 100, starting_after: last_id})
      last_id = list.data.last&.id
      has_more = list.has_more
      list.data.each do |customer|
        emails << customer.email
        next if customer.email.present?
        Stripe::Customer.delete(customer.id)
        p "Deleted: #{customer.id}, email: #{customer.email}"
      end
    end

    # 重複したemailを表示
    p emails.group_by(&:itself).map{ |k,v| [k, v.count] }.to_h.filter{|k,v| v > 1}.keys
  end
end
