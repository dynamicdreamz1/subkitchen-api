class AddPurchasedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :purchased, :boolean, default: false
  end
end
