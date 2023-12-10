class MoveDeliveryTimeFromChannelToAssignment < ActiveRecord::Migration[6.0]
  def change
    remove_column :channels, :delivery_time, :time, null: false, default: '07:00:00'
    add_column :distributions, :delivery_time, :time, null: false, default: '07:00:00'
  end
end
