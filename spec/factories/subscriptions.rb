FactoryBot.define do
  factory :subscription do
    association :user
    association :book_assignment
    delivery_method { "email" }
  end
end
