class FeedDeliveryJob < ApplicationJob
  queue_as :delivery

  def perform(feed:)
    feed.deliver
  end
end
