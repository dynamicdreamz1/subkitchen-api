class RemoveTemplateVariantIdFormProducts < ActiveRecord::Migration
  def change
    remove_column :products, :template_variant_id, :integer
    add_column :products, :product_template_id, :integer
  end
end
