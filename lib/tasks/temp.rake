namespace :temp do
  # Stripeのcustomerにデフォルト支払い方法を設定
  task set_default_payment_method: :environment do |_task, _args|
    emails = User.active_emails_in_stripe
    User.where(email: emails).each do |user|
      # Customer取得
      customer = Stripe::Customer.retrieve(user.stripe_customer_id) rescue nil
      if !customer
        p "Customer not found: #{user.stripe_customer_id}"
        next
      end

      # PaymentMethod取得（複数設定されてるときはアラート出して後から手動対応）
      payment_methods = Stripe::PaymentMethod.list({customer: customer.id, type: 'card'})
      if payment_methods.data.length > 1
        p "Multiple methods for cus: #{customer.id}"
        next
      end
      pm = payment_methods.data.first

      # PaymentMethodをデフォルト支払い方法に設定
      Stripe::Customer.update(customer.id, {invoice_settings: {default_payment_method: pm.id}})
      p "Updated cus: #{customer.id}"
      sleep 0.3
    end
  end

  task :webpush_test, ['feed_id', 'run_at'] => :environment do |_task, args|
    user = User.find_by(email: "tomomichi.onishi@gmail.com")
    feed = Feed.find(args[:feed_id])
    run_at = Time.zone.parse(args[:run_at])
    WebPushJob.set(wait_until: run_at).perform_later(user: user, message: feed.send("webpush_payload"))
  end


  task cancel_stripe_subscriptions: :environment do |_task, _args|
    subs = Stripe::Subscription.list({limit: 100})
    subs.auto_paging_each do |sub|
      Stripe::Subscription.cancel(sub.id)
      p "Canceled: #{sub.id}"
    end
  end
end
