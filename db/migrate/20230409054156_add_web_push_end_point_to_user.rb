class AddWebPushEndPointToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :webpush_endpoint, :string
    add_column :users, :webpush_p256dh, :string
    add_column :users, :webpush_auth, :string
  end
end
