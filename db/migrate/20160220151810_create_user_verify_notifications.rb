class CreateUserVerifyNotifications < ActiveRecord::Migration
  def change
    create_table :user_verify_notifications do |t|
      t.text :params
      t.integer :order_id
      t.string :status
      t.string :transaction_id

      t.timestamps null: false
    end
  end
end
