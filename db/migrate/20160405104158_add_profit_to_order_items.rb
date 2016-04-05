class AddProfitToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :profit, :decimal, precision: 8, scale: 2
  end
end
