class AddDesignFieldsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :design_size, :integer
    add_column :products, :design_content_type, :string
  end
end
