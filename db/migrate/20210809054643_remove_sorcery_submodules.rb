class RemoveSorcerySubmodules < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, :magic_login_token
    remove_column :users, :magic_login_token, :string, default: nil
    remove_column :users, :magic_login_token_expires_at, :datetime, default: nil
    remove_column :users, :magic_login_email_sent_at, :datetime, default: nil

    remove_index :users, :remember_me_token
    remove_column :users, :remember_me_token, :string, default: nil
    remove_column :users, :remember_me_token_expires_at, :datetime, default: nil

    remove_index :users, :activation_token
    remove_column :users, :activation_state, :string, default: nil
    remove_column :users, :activation_token, :string, default: nil
    remove_column :users, :activation_token_expires_at, :datetime, default: nil
  end
end
