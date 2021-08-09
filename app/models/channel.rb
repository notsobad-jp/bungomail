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

  OFFICIAL_CHANNEL_ID = '1418479c-d5a7-4d29-a174-c5133ca484b6'
  NOVEL_CHANNEL_ID = '470a73fb-d1ae-4ffb-9c6b-5b9dc292f4ef'
  PUBLIC_CHANNEL_CODES = %w(bungomail-official long-novel dogramagra alterego business-model) # channels#indexではこの並び順で表示


  def finished?
    %w(dogramagra business-model alterego).include?(code)
  end

  def nearest_assignable_date
    return Time.zone.tomorrow if book_assignments.blank?
    [book_assignments.maximum(:end_date), Time.zone.today].max.next_day
  end

  # 検索条件をもとに本を1冊ピックアップ
  def pick_book(q)
    books = AozoraBook.search(q).where.not(id: book_assignments.pluck(:book_id)) # 配信済みの作品は除外
    books = books.where.not(author_id: recent_author_ids) if q[:author].blank? # 著者指定なければ、直近で配信した著者も避ける
    id = books.ids.sample
    AozoraBook.find_by(id: id)
  end

  def public?
    code.present?
  end

  # 直近のn作品で配信したauthorのid一覧
  def recent_author_ids(n=6)
    book_assignments.order(start_date: :desc).limit(n).preload(:book).map{|ba| ba.book.author_id}
  end

  # 購読に必要な契約プラン
  ## 公開チャネルはfree, 公式チャネルやカスタム配信はbasicプランから
  def required_plan
    (public? && code != 'bungomail-official') ? 'free' : 'basic'
  end
end
