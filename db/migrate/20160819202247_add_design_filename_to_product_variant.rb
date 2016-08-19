class AddDesignFilenameToProductVariant < ActiveRecord::Migration
  def change
    add_column :product_variants, :design_filename, :string
  end
end
