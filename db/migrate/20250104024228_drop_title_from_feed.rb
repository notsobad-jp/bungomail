class DropTitleFromFeed < ActiveRecord::Migration[8.0]
  def change
    remove_column :feeds, :title, :string
  end
end
