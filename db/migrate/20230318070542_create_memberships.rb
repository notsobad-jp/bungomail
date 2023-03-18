class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :plan, null: false, default: "free"
      t.boolean :trialing, null: false, default: false
      t.date :apply_at, null: false, index: true, default: -> { 'CURRENT_DATE' }
      t.boolean :canceled, default: false, index: true, null: false
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :memberships, [:user_id, :apply_at, :canceled], unique: true
  end
end
