class AddStyleToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :style, :string
  end
end
