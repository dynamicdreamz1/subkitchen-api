class AddOrderItemsCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :order_items_count, :integer, default: 0
  end
end
