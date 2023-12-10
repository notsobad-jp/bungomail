class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :distribution

  enum delivery_method: { "Eメール" => "email", "プッシュ通知" => "webpush" }
end
