class FeedDeliveryJob < ActiveJob::Base
  def perform(feed_id:)
    Feed.find(feed_id).deliver
  end
end
