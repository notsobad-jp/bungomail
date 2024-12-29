namespace :cron do
  # [月初] Stripe登録状況とSubscriptionを一致させる
  task sync_stripe_subscription: :environment do |_task, _args|
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # stripeで支払い中のメールアドレス一覧
      emails = User.active_emails_in_stripe

      # 解約した人のstatus更新
      unsubs = User.canceled_in_stripe(emails)
      unsubs.update_all(plan: :free, updated_at: Time.current)
      p "UnSubscribed users: #{unsubs.map(&:email)}"

      # 新規契約した人のstatus更新
      new_subs = User.activated_in_stripe(emails)
      new_subs.update_all(plan: :basic, updated_at: Time.current)
      p "Subscribing users: #{new_subs.map(&:email)}"

      # 月初時点で有料の人はトライアル体験済みにする
      digests = new_subs.map{|user| Digest::SHA256.hexdigest(user.email) }
      EmailDigest.where(digest: digests).update_all(trial_ended: true, updated_at: Time.current)

      # 有料じゃないユーザーのcampaignsは全部削除
      Campaign.by_unpaid_users.upcoming.destroy_all
    end
  end

  # [随時] 決済画面遷移時に作成されるcustomerのうち、決済情報を登録せずに離脱したemailなしcustomerを定期的に削除する
  task clean_stripe_blank_accounts: :environment do |_task, _args|
    emails = []
    customers = Stripe::Customer.list({limit: 100})
    customers.auto_paging_each do |customer|
      emails << customer.email
      next if customer.email.present?
      Stripe::Customer.delete(customer.id)
      p "Deleted: #{customer.id}, email: #{customer.email}"
    end

    # 重複したemailを表示
    p emails.group_by(&:itself).map{ |k,v| [k, v.count] }.to_h.filter{|k,v| v > 1}.keys
  end
end
