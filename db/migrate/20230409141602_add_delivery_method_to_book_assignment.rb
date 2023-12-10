class AddDeliveryMethodToDistribution < ActiveRecord::Migration[7.0]
  def change
    add_column :distributions, :delivery_method, :string, null: false, default: "email"
  end
end
