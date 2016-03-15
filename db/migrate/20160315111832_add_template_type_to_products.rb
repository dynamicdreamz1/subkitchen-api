class AddTemplateTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :template_type, :string
  end
end
