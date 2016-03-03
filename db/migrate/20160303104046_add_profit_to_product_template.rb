class AddProfitToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :profit, :decimal, precision: 8, scale: 2
  end
end
