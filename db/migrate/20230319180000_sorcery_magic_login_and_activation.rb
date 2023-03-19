class SorceryMagicLoginAndActivation < ActiveRecord::Migration[6.0]
  def change
    # magic login
    add_column :users, :magic_login_token, :string, default: nil
    add_column :users, :magic_login_token_expires_at, :datetime, default: nil
    add_column :users, :magic_login_email_sent_at, :datetime, default: nil

    add_index :users, :magic_login_token

    # activation
    add_column :users, :activation_state, :string, default: nil
    add_column :users, :activation_token, :string, default: nil
    add_column :users, :activation_token_expires_at, :datetime, default: nil

    add_index :users, :activation_token
  end
end
