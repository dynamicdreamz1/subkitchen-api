class RemoveProductColumnsFromOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :product_name, :string
    remove_column :order_items, :product_description, :string
    remove_column :order_items, :product_author, :string
  end
end
