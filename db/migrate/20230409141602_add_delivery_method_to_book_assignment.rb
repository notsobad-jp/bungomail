class AddDeliveryMethodToBookAssignment < ActiveRecord::Migration[7.0]
  def change
    add_column :book_assignments, :delivery_method, :string, null: false, default: "email"
  end
end
