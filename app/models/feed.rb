class Feed < ApplicationRecord
  belongs_to :book_assignment
  belongs_to :delayed_job, required: false

  # 配信日が昨日以前のもの or 配信日が今日ですでに配信時刻を過ぎているもの
  scope :delivered, -> { Feed.joins(:book_assignment).where("delivery_date < ?", Time.zone.today).or(Feed.joins(:book_assignment).where(delivery_date: Time.zone.today).where("book_assignments.delivery_time < ?", Time.current.strftime("%T"))) }

  after_destroy do
    self.delayed_job&.delete
  end


  def schedule
    return if self.send_at < Time.current
    res = BungoMailer.with(feed: self).feed_email.deliver_later(queue: 'feed_email', wait_until: self.send_at)
    self.update!(delayed_job_id: res.provider_job_id)
  end

  def send_at
    Time.zone.parse("#{delivery_date.to_s} #{book_assignment.delivery_time}")
  end
end
