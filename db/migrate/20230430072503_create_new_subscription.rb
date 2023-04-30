class CreateNewSubscription < ActiveRecord::Migration[7.0]
  def up
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :book_assignment, type: :uuid, null: false, foreign_key: true
      t.string :delivery_method, null: false, default: "email"
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :subscriptions, [:user_id, :book_assignment_id], unique: true
    add_index :subscriptions, :delivery_method

    # book_assignmentsのデータをsubscriptionsに移行
    execute <<-SQL
      INSERT INTO subscriptions (user_id, book_assignment_id, delivery_method)
      SELECT user_id, id, delivery_method FROM book_assignments
    SQL

    # book_assignmentsからdelivery_methodを削除
    remove_column :book_assignments, :delivery_method, :string, null: false, default: "email"
  end

  def down
    # book_assignmentsにdelivery_methodを追加
    add_column :book_assignments, :delivery_method, :string, null: false, default: "email"

    # subscriptionsのデータをbook_assignmentsに移行
    execute <<-SQL
      UPDATE book_assignments
      SET delivery_method = subscriptions.delivery_method
      FROM subscriptions
      WHERE book_assignments.id = subscriptions.book_assignment_id
    SQL

    drop_table :subscriptions
  end
end
