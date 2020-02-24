# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  crypted_password             :string
#  email                        :string           not null
#  magic_login_email_sent_at    :datetime
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#  salt                         :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_users_on_email              (email) UNIQUE
#  index_users_on_magic_login_token  (magic_login_token)
#  index_users_on_remember_me_token  (remember_me_token)
#

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :charge, dependent: :destroy
  has_many :assigned_books, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  # ユーザー作成時にmagic_login_tokenも発行しておく
  after_create do
    self.generate_magic_login_token!
  end

  def select_book
    # LIKE > 30 : 1094冊
    # LIKE > 100 : 245冊（最初はおもしろそうなやつを）
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights: 'Public domain in the USA.', words_count: 5000..40000).where("downloads > ?", 100).order(Arel.sql("RANDOM()")).first
  end

  def assign_book_and_set_feeds(start_from: Time.zone.today, deliver_now: false)
    book = self.select_book
    assigned_book = self.assigned_books.create(guten_book_id: book.id)
    assigned_book.set_feeds(start_from: start_from)

    # TODO: UTCの配信時間以前なら予約・以降ならすぐに配信される
    UserMailer.feed_email(assigned_book.feeds.first).deliver if deliver_now
  end
end
