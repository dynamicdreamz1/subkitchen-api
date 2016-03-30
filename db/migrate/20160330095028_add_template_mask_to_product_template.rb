class AddTemplateMaskToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :template_mask_id, :string
  end
end
