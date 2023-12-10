class AddTwitterShareUrlToDistribution < ActiveRecord::Migration[6.0]
  def change
    add_column :distributions, :twitter_share_url, :string
  end
end
