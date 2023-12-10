class CreateChannelProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :channels, :code, :string
    add_index :channels, :code, unique: true
    remove_column :channels, :public, :boolean, default: false
    remove_column :channels, :send_to, :string
    remove_column :channels, :title, :string

    create_table :channel_profiles, id: :uuid do |t|
      t.string :send_to
      t.string :title
      t.text :description
      t.timestamps
    end
    add_foreign_key :channel_profiles, :channels, column: :id

    add_index :distributions, :start_at
  end
end
