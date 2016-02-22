class AddOrderTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_type, :string, default: :cart
  end
end
