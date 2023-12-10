class AddDeliveryTimeToChannel < ActiveRecord::Migration[6.0]
  def up
    add_column :channels, :delivery_time, :time, null: false, default: '07:00:00'
    rename_column :distributions, :start_at, :start_date
    change_column :distributions, :start_date, :date, null: false
    rename_column :chapters, :send_at, :delivery_date
    change_column :chapters, :delivery_date, :date, null: false
  end

  def down
    remove_column :channels, :delivery_time
    rename_column :distributions, :start_date, :start_at
    change_column :distributions, :start_at, :datetime, null: false
    rename_column :chapters, :delivery_date, :send_at
    change_column :chapters, :send_at, :datetime, null: false
  end
end
