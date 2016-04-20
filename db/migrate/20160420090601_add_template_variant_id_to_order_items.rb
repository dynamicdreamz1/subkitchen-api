class AddTemplateVariantIdToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :template_variant_id, :integer
  end
end
