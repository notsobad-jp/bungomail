class DropFeed < ActiveRecord::Migration[7.0]
  def change
    drop_table :feeds
  end
end
