class DelayedJob < ApplicationRecord
  has_one :feed, dependent: :nullify
end
