class CreateProductTemplates < ActiveRecord::Migration
  def change
    create_table :product_templates do |t|
      t.decimal :price, precision: 8, scale: 2
      t.string :product_type
      t.string :size
      t.timestamps null: false
    end
  end
end
