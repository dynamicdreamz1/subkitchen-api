class ChangeOrderStatus < ActiveRecord::Migration
  def change
    remove_column :orders, :order_status, :string
    add_column :orders, :order_status, :integer, default: 0
  end
end
