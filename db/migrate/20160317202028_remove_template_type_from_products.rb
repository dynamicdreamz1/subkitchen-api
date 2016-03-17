class RemoveTemplateTypeFromProducts < ActiveRecord::Migration
  def change
    remove_column :products, :template_type, :string
  end
end
