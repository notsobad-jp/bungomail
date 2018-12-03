# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  current_book_id   :bigint(8)
#  index             :integer
#  title             :string           not null
#  description       :text
#  deliver_at        :integer          default(["8"]), is an Array
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Channel < ApplicationRecord
  belongs_to :user
  belongs_to :current_book, class_name: 'Book', foreign_key: 'current_book_id', optional: true
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true


  def publish
    next_book = self.channel_books.where(delivered: false).first
    return if !next_book
    self.update(current_book_id: next_book.book_id, index: 1)
    next_book.update(delivered: true)
  end

  def publishable?
    # 現在配信中ではなくて、かつ配信待ちの本が存在する
    self.current_book_id.blank? && self.channel_books.find_by(delivered: false)
  end

  def set_next_chapter
    # 同じ本で次のchapterが存在すればindexをincrement
    next_chapter = Chapter.find_by(book_id: self.current_book_id, index: self.index + 1)
    return self.increment(:index).save if next_chapter

    # 次のchapterがなければ、次の本を探してindex:1でセット
    current_book = self.channel_books.find_by(book_id: self.current_book_id)
    next_book = self.channel_books.find_by(index: current_book.index + 1)

    if next_book
      self.update(current_book_id: next_book.id, index: 1)
      next_book.update(delivered: true)
    else
      self.update(current_book_id: nil, index: nil)
    end
  end
end
