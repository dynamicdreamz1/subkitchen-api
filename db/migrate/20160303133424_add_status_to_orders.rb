class AddStatusToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_status, :string, default: 'creating'
  end
end
