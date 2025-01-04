class FeedDeliveryJob < ActiveJob::Base
  def perform(campaign_id:, index:, content:)
    Campaign.find(campaign_id).deliver(content)
  end
end
