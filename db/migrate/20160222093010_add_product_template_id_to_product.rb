class AddProductTemplateIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :product_template_id, :integer
  end
end
