class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true, null: false
      t.references :channel, foreign_key: true, null: false
      t.text :deliver_at, null: false

      t.timestamps
    end
    add_index :subscriptions, [:user_id, :channel_id], unique: true
  end
end
