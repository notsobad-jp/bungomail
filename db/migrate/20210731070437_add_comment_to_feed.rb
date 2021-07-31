class AddCommentToFeed < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :comment, :text
  end
end
