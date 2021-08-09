class AddMembershipStatusToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :paid_member, :boolean, null: false, default: false
    add_column :users, :trial_start_date, :date
    add_column :users, :trial_end_date, :date

    remove_column :email_digests, :trial_ended_at, :datetime
    add_column :email_digests, :trial_ended, :boolean, null: false, default: false
    add_column :email_digests, :canceled_at, :datetime
    add_index :email_digests, :canceled_at
  end
end
