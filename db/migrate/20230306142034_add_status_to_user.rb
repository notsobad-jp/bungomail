class AddStatusToUser < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :status, :integer, limit: 1, default: 1, null: false
    add_index :users, :status

    # ユーザーの状態に応じてstatusを設定する
  end

  def down
    remove_column :users, :status
  end
end
