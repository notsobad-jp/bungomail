class AddFeedsCountToAssignedBook < ActiveRecord::Migration[5.2]
  def change
    add_column :assigned_books, :feeds_count, :integer, default: 0
  end
end
