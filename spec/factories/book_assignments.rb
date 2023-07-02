FactoryBot.define do
  factory :book_assignment do
    association :user
    book_id { 1567 }
    book_type { 'AozoraBook' }
    start_date { Time.zone.today.next_month.beginning_of_month }
    end_date { start_date + 29 }

    trait :with_book do
      before(:create) { |ba| create(:aozora_book_meros) }
    end

    trait :with_subscription do
      after(:create) { |ba| create(:subscription, book_assignment: ba, user: ba.user) }
    end
  end
end
