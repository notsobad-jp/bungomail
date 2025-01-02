class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  enum delivery_method: { "Eメール" => "email", "プッシュ通知" => "webpush" }

  after_create do
    if delivery_method == "プッシュ通知" && user.fcm_device_token.present?
      Webpush.subscribe_to_topic!(
        token: user.fcm_device_token,
        topic: campaign_id
      )
    end
  end
end
