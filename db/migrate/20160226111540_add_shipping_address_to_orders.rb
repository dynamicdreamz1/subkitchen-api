class AddShippingAddressToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :first_name, :string
    add_column :orders, :last_name, :string
    add_column :orders, :address, :string
    add_column :orders, :city, :string
    add_column :orders, :zip, :string
    add_column :orders, :region, :string
    add_column :orders, :country, :string
    add_column :orders, :phone, :string
  end
end
