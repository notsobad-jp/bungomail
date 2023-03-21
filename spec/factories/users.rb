FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com"}
    plan { 'free' }

    trait :trial_scheduled do
      trial_start_date { Time.zone.today.next_month.beginning_of_month }
      trial_end_date { Time.zone.today.next_month.end_of_month }
    end

    trait :trialing do
      plan { 'basic' }
      trial_start_date { Time.zone.today.beginning_of_month }
      trial_end_date { Time.zone.today.end_of_month }
    end

    trait :basic do
      plan { 'basic' }
      trial_start_date { Time.zone.today.prev_month.beginning_of_month }
      trial_end_date { Time.zone.today.prev_month.end_of_month }
    end
  end
end
