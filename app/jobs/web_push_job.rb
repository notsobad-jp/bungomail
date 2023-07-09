class WebPushJob < ApplicationJob
  queue_as :web_push

  def perform(feed:, payload:)
    users = feed.book_assignment.subscriptions.deliver_by_webpush.preload(:user).map(&:user)
    return if users.blank?

    payload_json = JSON.generate(payload)
    public_key = Rails.application.credentials.dig(:vapid, :public_key)
    private_key = Rails.application.credentials.dig(:vapid, :private_key)

    users.each do |user|
      next if user.webpush_endpoint.blank? || user.webpush_p256dh.blank? || user.webpush_auth.blank?

      begin
        WebPush.payload_send(
          message: payload_json,
          endpoint: user.webpush_endpoint,
          p256dh: user.webpush_p256dh,
          auth: user.webpush_auth,
          vapid: {
            subject: "mailto:info@notsobad.jp",
            public_key: public_key,
            private_key: private_key,
            expiration: 12 * 60 * 60,
          },
        )
      rescue => exception
        # WebPushに失敗したら、ユーザーのWebPush情報を削除して通知メールを送信する
        Rails.logger.warn("WebPushJob failed: [#{user.id}] #{exception.message}")
        user.update!(webpush_endpoint: nil, webpush_p256dh: nil, webpush_auth: nil)
        BungoMailer.with(user: user).webpush_failed_email.deliver_now
      end
    end
  end
end
