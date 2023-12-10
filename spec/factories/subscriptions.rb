FactoryBot.define do
  factory :subscription do
    association :user
    association :distribution
    delivery_method { "email" }
  end
end
