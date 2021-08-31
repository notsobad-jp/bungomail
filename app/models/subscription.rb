class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  scope :by_unpaid_users, -> { joins(:user).where(users: { paid_member: false }) }
end
