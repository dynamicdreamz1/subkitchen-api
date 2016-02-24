class RemoveShippingIdFromProductTemplate < ActiveRecord::Migration
  def change
    remove_column :product_templates, :shipping_id, :integer
  end
end
