class WebPushJob < ApplicationJob
  queue_as :default

  def perform(user:, message:)
    WebPush.payload_send(
      message: JSON.generate(message),
      endpoint: user.webpush_endpoint,
      p256dh: user.webpush_p256dh,
      auth: user.webpush_auth,
      vapid: {
        subject: "mailto:info@notsobad.jp",
        public_key: Rails.application.credentials.dig(:vapid, :public_key),
        private_key: Rails.application.credentials.dig(:vapid, :private_key),
        expiration: 12 * 60 * 60,
      },
    )
  end
end
