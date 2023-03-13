class DropUnusedTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :campaigns
    drop_table :campaign_groups
    drop_table :channel_subscription_logs
    drop_table :marketing_emails
    drop_table :senders
  end
end
