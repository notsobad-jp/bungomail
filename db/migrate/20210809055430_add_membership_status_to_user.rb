class AddMembershipStatusToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :paid_member, :boolean, null: false, default: false
    add_column :users, :trial_start_date, :date
    add_column :users, :trial_end_date, :date
  end
end
