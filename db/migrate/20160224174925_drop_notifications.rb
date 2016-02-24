class DropNotifications < ActiveRecord::Migration
  def change
    drop_table :user_verify_notifications
    drop_table :payment_notifications
  end
end
