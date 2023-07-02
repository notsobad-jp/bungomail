class BookAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :book, polymorphic: true
  has_many :feeds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :delayed_job_for_emails, through: :feeds
  has_many :delayed_job_for_webpushs, through: :feeds

  scope :by_unpaid_users, -> { joins(:user).where(users: { plan: 'free' }) }
  scope :upcoming, -> { where("? <= end_date", Date.current) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :delivery_should_start_after_trial # トライアル開始前の配信予約は不可
  validate :end_date_should_come_after_start_date
  validate :delivery_period_should_not_overlap # 同一チャネルで期間が重複するレコードが存在すればinvalid
  validate :end_date_should_not_be_too_far # 12ヶ月以上先の予約は禁止


  def count
    (end_date - start_date).to_i + 1
  end

  def create_and_schedule_feeds
    feed_ids = create_feeds
    Feed.find(feed_ids).map(&:schedule)
  end

  def create_feeds
    feeds = []
    contents = self.book.contents(count: count)
    delivery_date = self.start_date

    contents.each.with_index(1) do |content, index|
      title = self.book.title
      feeds << {
        title: title,
        content: content,
        delivery_date: delivery_date,
        book_assignment_id: self.id
      }
      delivery_date += 1.day
    end
    res = Feed.insert_all feeds
    res.rows.flatten  # 作成したfeedのid一覧を配列で返す
  end

  # 配信対象
  ## 公式チャネルのときは有料会員全員。それ以外のときは配信オーナーのみ
  def send_to
    user.admin? ? User.basic_plan.pluck(:email) : [user.email]
  end

  def status
    if Date.current < start_date
      "配信予定"
    elsif Date.current > end_date
      "配信終了"
    else
      "配信中"
    end
  end

  def status_color
    case status
    when "配信予定"
      "blue"
    when "配信中"
      "orange"
    when "配信終了"
      "gray"
    end
  end

  def twitter_short_url
    begin
      Bitly.call(path: 'shorten', params: { long_url: self.twitter_long_url })
    rescue => e
      logger.error "[Error] Bitly API failed: #{e}"
    end
  end

  def twitter_long_url
    "https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール,青空文庫&text=#{start_date.month}月は%20%23#{book.author_name}%20%23#{book.title}%20を配信中！"
  end


  private

  # 同一チャネルで期間が重複するレコードが存在すればinvalid(Freeプランのみ)
  def delivery_period_should_not_overlap
    return if user.basic_plan? # Basicプランは重複許可
    overlapping = BookAssignment.where.not(id: id).where(user_id: user_id).where("end_date >= ? and ? >= start_date", start_date, end_date)
    errors.add(:base, "予約済みの配信と期間が重複しています") if overlapping.present?
  end

  def end_date_should_come_after_start_date
    errors.add(:base, "配信終了日は開始日より後に設定してください") if end_date < start_date
  end

  def end_date_should_not_be_too_far
    errors.add(:base, "配信終了日は現在から12ヶ月以内に設定してください") if end_date > Date.current.since(12.months)
  end

  def delivery_should_start_after_trial
    errors.add(:base, "配信開始日は無料トライアルの開始日以降に設定してください") if user.trial_start_date && start_date < user.trial_start_date
  end
end
