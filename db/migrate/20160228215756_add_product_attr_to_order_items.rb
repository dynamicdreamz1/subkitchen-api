class AddProductAttrToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :product_name, :string
    add_column :order_items, :product_description, :string
    add_column :order_items, :product_author, :string
  end
end
