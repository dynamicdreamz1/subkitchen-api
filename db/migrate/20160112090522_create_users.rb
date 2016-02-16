class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :uid
      t.string :auth_token, null: false
      t.string :password_reminder_token
      t.datetime :password_reminder_expiration
      t.timestamps null: false
    end

    add_index :users, :auth_token, unique: true
    add_index :users, :password_reminder_token, unique: true
  end
end
