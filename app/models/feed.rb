class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :campaign
  belongs_to :delayed_job, required: false

  # 配信日が昨日以前のもの or 配信日が今日ですでに配信時刻を過ぎているもの
  scope :delivered, -> { Feed.joins(:campaign).where("delivery_date < ?", Time.zone.today).or(Feed.joins(:campaign).where(delivery_date: Time.zone.today).where("campaigns.delivery_time < ?", Time.current.strftime("%T"))) }

  after_destroy do
    self.delayed_job&.delete
  end

  def deliver
    BungoMailer.with(feed: self).feed_email.deliver_now
    Webpush.notify(webpush_payload)
  end

  def index
    (delivery_date - campaign.start_date).to_i + 1
  end

  def schedule
    return if send_at < Time.current

    res = FeedDeliveryJob.set(wait_until: send_at).perform_later(feed: self)
    update!(delayed_job_id: res.provider_job_id)
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{campaign.delivery_time}")
  end

  private

    def webpush_payload
      {
        message: {
          name: id,
          topic: campaign_id,
          notification: {
            title: "#{campaign.book.author_name}『#{campaign.book.title}』",
            body: content.truncate(100),
            image: "https://bungomail.com/favicon.ico",
          },
          webpush: {
            fcm_options: {
              link: feed_url(id, host: Rails.env.production? ? "https://bungomail.com" : "http://localhost:3000"),
            }
          },
        }
      }
    end
end
