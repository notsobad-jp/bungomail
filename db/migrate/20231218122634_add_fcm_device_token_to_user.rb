class AddFcmDeviceTokenToUser < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :webpush_endpoint, :string
    remove_column :users, :webpush_p256dh, :string
    remove_column :users, :webpush_auth, :string
    add_column :users, :fcm_device_token, :string
  end
end
