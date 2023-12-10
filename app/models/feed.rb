class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :distribution
  belongs_to :delayed_job, required: false

  # 配信日が昨日以前のもの or 配信日が今日ですでに配信時刻を過ぎているもの
  scope :delivered, -> { Feed.joins(:distribution).where("delivery_date < ?", Time.zone.today).or(Feed.joins(:distribution).where(delivery_date: Time.zone.today).where("distributions.delivery_time < ?", Time.current.strftime("%T"))) }

  after_destroy do
    self.delayed_job&.delete
  end

  def deliver
    BungoMailer.with(feed: self).feed_email.deliver_now
    deliver_webpush
  end

  def index
    (delivery_date - distribution.start_date).to_i + 1
  end

  def schedule
    return if send_at < Time.current

    res = FeedDeliveryJob.set(wait_until: send_at).perform_later(feed: self)
    update!(delayed_job_id: res.provider_job_id)
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{distribution.delivery_time}")
  end

  private

    def deliver_webpush
      users = distribution.subscriptions.where(delivery_method: :webpush).preload(:user).map(&:user)
      return if users.blank?

      payload_json = JSON.generate(webpush_payload)
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
          BungoMailer.with(user: user).webpush_failed_email.deliver_later
        end
      end
    end

    def host
      Rails.env.production? ? "https://bungomail.com" : "http://localhost:3000"
    end

    def webpush_payload
      {
        title: "#{distribution.book.author_name}『#{distribution.book.title}』",
        body: content.truncate(100),
        icon: "https://bungomail.com/favicon.ico",
        url: feed_url(id, host: host),
      }
    end
end
