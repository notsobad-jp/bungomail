FactoryBot.define do
  factory :subscription do
    association :user
    association :channel
  end
end
