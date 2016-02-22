class AddShippingIdToProductTemplates < ActiveRecord::Migration
  def change
    add_column :product_templates, :shipping_id, :integer
  end
end
