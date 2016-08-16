class AddDesignFieldsToProductVariant < ActiveRecord::Migration
  def change
    add_column :product_variants, :design_size, :integer
    add_column :product_variants, :design_content_type, :string
  end
end
