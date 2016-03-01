class AddAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, default: ''
    add_column :users, :last_name, :string, default: ''
    add_column :users, :address, :string, default: ''
    add_column :users, :city, :string, default: ''
    add_column :users, :zip, :string, default: ''
    add_column :users, :state, :string, default: ''
    add_column :users, :country, :string, default: ''
    add_column :users, :phone, :string, default: ''
  end
end
