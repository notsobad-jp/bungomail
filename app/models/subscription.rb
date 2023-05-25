class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :book_assignment

  enum delivery_method: { "Eメール" => "email", "プッシュ通知" => "webpush" }
end
