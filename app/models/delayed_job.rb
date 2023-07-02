class DelayedJob < ApplicationRecord
  has_one :feed_for_email, class_name: 'Feed', foreign_key: :delayed_job_email_id, dependent: :nullify
  has_one :feed_for_webpush, class_name: 'Feed', foreign_key: :delayed_job_webpush_id, dependent: :nullify
end
