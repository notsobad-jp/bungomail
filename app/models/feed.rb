class Feed
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Rails.application.routes.url_helpers

  attribute :content, :string
  attribute :delivery_date, :date
  attribute :campaign

  def deliver
    BungoMailer.with(feed: self).feed_email.deliver_now
    Webpush.notify(webpush_payload)
    campaign.update(latest_feed: { content:, delivery_date: })
  end

  def index
    (delivery_date - campaign.start_date).to_i + 1
  end

  def schedule
    return if send_at < Time.current

    delay(run_at: send_at, queue: campaign.id).deliver
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{campaign.delivery_time}")
  end

  private

    def webpush_payload
      {
        message: {
          name: "#{campaign.id}-#{index}",
          topic: campaign.id,
          notification: {
            title: campaign.author_and_book_name,
            body: content.truncate(100),
            image: "https://bungomail.com/favicon.ico",
          },
          webpush: {
            fcm_options: {
              link: latest_feed_url(campaign.id, host: Rails.env.production? ? "https://bungomail.com" : "http://localhost:3000"),
            }
          },
        }
      }
    end
end
