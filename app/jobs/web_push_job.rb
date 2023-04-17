class WebPushJob < ApplicationJob
  queue_as :web_push

  def perform(user:, message:)
    @user = user
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

  # WebPushに失敗したら、ユーザーのWebPush情報を削除して通知メールを送信する
  rescue_from(StandardError) do |exception|
    Rails.logger.error("WebPushJob failed: [#{@user.id}] #{exception.message}")
    @user.update!(webpush_endpoint: nil, webpush_p256dh: nil, webpush_auth: nil)
    BungoMailer.with(user: @user).webpush_failed_email.deliver_now
  end
end
