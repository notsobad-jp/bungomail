class CreateNewSubscription < ActiveRecord::Migration[7.0]
  def up
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :distribution, type: :uuid, null: false, foreign_key: true
      t.string :delivery_method, null: false, default: "email"
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :subscriptions, [:user_id, :distribution_id], unique: true
    add_index :subscriptions, :delivery_method

    # distributionsのデータをsubscriptionsに移行
    execute <<-SQL
      INSERT INTO subscriptions (user_id, distribution_id, delivery_method)
      SELECT user_id, id, delivery_method FROM distributions
    SQL

    # distributionsからdelivery_methodを削除
    remove_column :distributions, :delivery_method, :string, null: false, default: "email"
  end

  def down
    # distributionsにdelivery_methodを追加
    add_column :distributions, :delivery_method, :string, null: false, default: "email"

    # subscriptionsのデータをdistributionsに移行
    execute <<-SQL
      UPDATE distributions
      SET delivery_method = subscriptions.delivery_method
      FROM subscriptions
      WHERE distributions.id = subscriptions.distribution_id
    SQL

    drop_table :subscriptions
  end
end
