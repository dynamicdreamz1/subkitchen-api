class AddIsDeletedToProductTemplates < ActiveRecord::Migration
  def change
    add_column :product_templates, :is_deleted, :boolean, default: false
  end
end
