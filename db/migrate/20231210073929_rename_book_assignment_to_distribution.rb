class RenameDistributionToDistribution < ActiveRecord::Migration[7.0]
  def change
    rename_table :distributions, :distributions
    rename_column :feeds, :distribution_id, :distribution_id
    rename_column :subscriptions, :distribution_id, :distribution_id
  end
end
