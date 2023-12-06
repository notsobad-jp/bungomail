class Feed < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :book_assignment
  belongs_to :delayed_job, required: false

  # 配信日が昨日以前のもの or 配信日が今日ですでに配信時刻を過ぎているもの
  scope :delivered, -> { Feed.joins(:book_assignment).where("delivery_date < ?", Time.zone.today).or(Feed.joins(:book_assignment).where(delivery_date: Time.zone.today).where("book_assignments.delivery_time < ?", Time.current.strftime("%T"))) }

  after_destroy do
    self.delayed_job&.delete
  end

  def index
    (delivery_date - book_assignment.start_date).to_i + 1
  end

  def schedule
    return if self.send_at < Time.current

    res_email = BungoMailer.with(feed: self).feed_email.deliver_later(queue: 'feed_email', wait_until: self.send_at)
    res_webpush = WebPushJob.set(wait_until: self.send_at).perform_later(feed: self, payload: webpush_payload)

    self.update!(
      delayed_job_email_id: res_email.provider_job_id,
      delayed_job_webpush_id: res_webpush.provider_job_id,
    )
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{book_assignment.delivery_time}")
  end

  private

    def webpush_payload
      {
        title: "#{book_assignment.book.author_name}『#{book_assignment.book.title}』",
        body: content.truncate(100),
        icon: "https://bungomail.com/favicon.ico",
        url: feed_url(id, host: host),
      }
    end

    def host
      Rails.env.production? ? "https://bungomail.com" : "http://localhost:3000"
    end
end
