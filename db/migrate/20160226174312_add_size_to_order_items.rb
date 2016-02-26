class AddSizeToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :size, :string
  end
end
