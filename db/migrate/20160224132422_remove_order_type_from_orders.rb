class RemoveOrderTypeFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :order_type, :string
  end
end
