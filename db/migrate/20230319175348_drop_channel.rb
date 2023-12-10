class DropChannel < ActiveRecord::Migration[7.0]
  def change
    add_reference :distributions, :user, type: :uuid, foreign_key: true
    execute <<~SQL
      UPDATE distributions AS ba SET user_id = channels.user_id
      FROM channels WHERE ba.channel_id = channels.id
    SQL
    change_column_null :distributions, :user_id, false
    remove_column :distributions, :channel_id
    drop_table :channel_profiles
    drop_table :subscriptions
    drop_table :channels
  end
end
