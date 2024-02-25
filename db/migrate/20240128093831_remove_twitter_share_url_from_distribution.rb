class RemoveTwitterShareUrlFromDistribution < ActiveRecord::Migration[7.0]
  def change
    remove_column :distributions, :twitter_share_url, :string
  end
end
