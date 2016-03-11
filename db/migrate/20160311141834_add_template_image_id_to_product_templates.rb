class AddTemplateImageIdToProductTemplates < ActiveRecord::Migration
  def change
    add_column :product_templates, :template_image_id, :string
  end
end
