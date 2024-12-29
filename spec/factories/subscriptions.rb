FactoryBot.define do
  factory :subscription do
    association :user
    association :campaign
    delivery_method { "email" }
  end
end
