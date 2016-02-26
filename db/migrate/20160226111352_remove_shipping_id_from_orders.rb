class RemoveShippingIdFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :shipping_id, :integer
  end
end
