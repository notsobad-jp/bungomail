FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com"}

    trait :with_novel_sub do
      after(:create) do |user|
        Subscription.insert({user_id: user.id, channel_id: Channel.find_by(code: 'long-novel').id})
      end
    end

    trait :with_official_sub do
      after(:create) do |user|
        Subscription.insert({user_id: user.id, channel_id: Channel.find_by(code: 'bungomail-official').id})
      end
    end
  end
end
