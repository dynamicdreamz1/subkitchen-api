class AddDescriptionToProductTemplates < ActiveRecord::Migration
  def change
    add_column :product_templates, :description, :string, default: ''
  end
end
