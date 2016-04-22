class AddDiscountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount, :decimal, precision: 8, scale: 2
  end
end
