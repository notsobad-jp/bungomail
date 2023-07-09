class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :book_assignment

  enum delivery_method: { "Eメール" => "email", "プッシュ通知" => "webpush" }

  scope :deliver_by_email, -> { where(delivery_method: :email) }
  scope :deliver_by_webpush, -> { where(delivery_method: :webpush) }
end
