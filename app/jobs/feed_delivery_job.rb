class FeedDeliveryJob < ApplicationJob
  queue_as :feed_delivery

  def perform(feed:)
    feed.deliver
  end
end
