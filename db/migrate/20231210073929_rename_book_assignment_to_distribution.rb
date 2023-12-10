class RenameBookAssignmentToDistribution < ActiveRecord::Migration[7.0]
  def change
    rename_table :book_assignments, :distributions
    rename_column :feeds, :book_assignment_id, :distribution_id
    rename_column :subscriptions, :book_assignment_id, :distribution_id
  end
end
