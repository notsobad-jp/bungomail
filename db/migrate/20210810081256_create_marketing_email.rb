class CreateMarketingEmail < ActiveRecord::Migration[6.0]
  def change
    create_table :marketing_emails, id: :uuid do |t|
      t.string :title, null: false
      t.text :content
      t.datetime :send_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
