FactoryBot.define do
  factory :channel do
    association :user
  end

  trait :with_book_assignment do
    after(:create) do |channel|
      channel.book_assignments << create(:book_assignment, :with_book)
    end
  end

  trait :with_channel_profile do
    after(:create) do |channel|
      channel.channel_profile = create(:channel_profile)
    end
  end
end
