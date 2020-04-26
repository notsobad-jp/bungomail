# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  crypted_password             :string
#  delivery_time                :string           default("07:00")
#  email                        :string           not null
#  magic_login_email_sent_at    :datetime
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#  salt                         :string
#  timezone                     :string           default("UTC")
#  words_per_day                :integer          default(400)
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
  has_one :default_channel, -> { where(default: true) }, class_name: 'Channel'
  has_many :channels, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :search_conditions, -> { order(created_at: :desc) }, dependent: :destroy
  accepts_nested_attributes_for :channels

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :timezone, presence: true

  after_create do
    self.generate_magic_login_token! # ユーザー作成時にmagic_login_tokenも発行しておく
    self.channels.create(title: 'Default Channel', default: true) # デフォルトchannel作成（さらにsubscriptionも作成される）
  end

  # 配信時間とTZの時差を調整して、UTCとのoffsetを算出（単位:minutes）
  def utc_offset
    # UTC00:00から配信時間までの分数（必ずプラス）
    ## "08:10" => [8, 10] => [480, 10] => +490(minutes)
    delivery_offset = self.delivery_time.split(":").map(&:to_i).zip([60, 1]).map{|a,b| a*b }.sum

    # UTCとユーザーTimezoneの差分（プラスマイナスどちらもありえる）
    timezone_offset = ActiveSupport::TimeZone.new(self.timezone).utc_offset / 60

    # offsetの結果、前日や翌日に日がまたぐ場合もいい感じに調整する（e.g. -01:00 => 23:00, 27:00 => 03:00）
    (delivery_offset - timezone_offset) % (24 * 60)
  end
end
