class DropChannel < ActiveRecord::Migration[7.0]
  def change
    add_reference :book_assignments, :user, type: :uuid, foreign_key: true
    execute <<~SQL
      UPDATE book_assignments AS ba SET user_id = channels.user_id
      FROM channels WHERE ba.channel_id = channels.id
    SQL
    change_column_null :book_assignments, :user_id, false
    remove_column :book_assignments, :channel_id
    drop_table :channel_profiles
    drop_table :subscriptions
    drop_table :channels
  end
end
