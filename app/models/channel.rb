class Channel < ApplicationRecord
  belongs_to :user
  has_one :channel_profile, foreign_key: :id, dependent: :destroy
  has_many :book_assignments, dependent: :destroy
  has_many :feeds, through: :book_assignments
  has_many :delayed_jobs, through: :book_assignments
  has_many :subscriptions, dependent: :destroy
  has_many :active_subscriptions, -> { where paused: false }, class_name: 'Subscription'
  has_many :active_subscribers, through: :active_subscriptions, source: :user

  delegate :title, :description, :google_group_key, to: :channel_profile, allow_nil: true

  # delivery_timeが更新されたときは予約中のjobの配信時間も更新する
  after_update  :update_jobs_run_at, if: :saved_change_to_delivery_time?

  OFFICIAL_CHANNEL_ID = '1418479c-d5a7-4d29-a174-c5133ca484b6'
  JUVENILE_CHANNEL_ID = '470a73fb-d1ae-4ffb-9c6b-5b9dc292f4ef'
  PUBLIC_CHANNEL_CODES = %w(bungomail-official juvenile dogramagra alterego business-model) # channels#indexではこの並び順で表示


  def finished?
    %w(dogramagra business-model alterego).include?(code)
  end

  def nearest_assignable_date
    return Time.zone.tomorrow if book_assignments.blank?
    [book_assignments.maximum(:end_date), Time.zone.today].max.next_day
  end

  # 検索条件をもとに本を1冊ピックアップしてidを返す(チャネルで過去に配信した作品は除外)
  def pick_book_id
    q = {}  # TODO
    AozoraBook.search(q).where.not(id: book_assignments.pluck(:book_id)).pluck(:id).sample
  end

  def public?
    code.present?
  end

  # 購読に必要な契約プラン
  ## 公開チャネルはfree, 公式チャネルやカスタム配信はbasicプランから
  def required_plan
    (public? && code != 'bungomail-official') ? 'free' : 'basic'
  end

  def update_jobs_run_at
    self.delayed_jobs.each do |job|
      run_at = job.run_at.change(hour: delivery_time.hour, min: delivery_time.min)
      job.update(run_at: run_at)
    end
  end
end
