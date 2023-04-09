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

  task webpush_test: :environment do |_task, _args|
    user = User.find_by(email: "tomomichi.onishi@gmail.com")
    WebPush.payload_send(
      message: "てすとだよーー",
      endpoint: user.webpush_endpoint,
      p256dh: user.webpush_p256dh,
      auth: user.webpush_auth,
      vapid: {
        subject: "mailto:sender@example.com",
        public_key: Rails.application.credentials.dig(:vapid, :public_key),
        private_key: Rails.application.credentials.dig(:vapid, :private_key),
        expiration: 12 * 60 * 60,
      },
    )
  end
end
