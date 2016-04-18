class AddTemplateVariantIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :template_variant_id, :integer
    remove_column :products, :product_template_id, :integer
  end
end
