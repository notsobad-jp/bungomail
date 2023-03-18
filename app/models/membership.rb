class Membership < ApplicationRecord
  belongs_to :user

  enum plan: { free: "free", basic: "basic" }
end
