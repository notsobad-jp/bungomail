class AddPlanToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :plan, :string, null: false, default: "free"
    execute <<~SQL
      UPDATE users SET plan = CASE WHEN paid_member = TRUE THEN 'basic'
                                   ELSE 'free'
                              END
    SQL
    remove_column :users, :paid_member, :boolean, null: false, default: false
  end
end
