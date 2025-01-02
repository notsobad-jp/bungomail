class AddLatestFeedToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :latest_feed, :text
  end
end
