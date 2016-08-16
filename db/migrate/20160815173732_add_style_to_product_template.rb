class AddStyleToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :style, :string
  end
end
