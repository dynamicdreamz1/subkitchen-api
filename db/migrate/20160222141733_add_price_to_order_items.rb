class AddPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :price, :decimal, precision: 8, scale: 2
  end
end
