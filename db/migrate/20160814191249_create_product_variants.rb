class CreateProductVariants < ActiveRecord::Migration
  def change
    create_table :product_variants do |t|
      t.references :product, index: true, foreign_key: true
      t.string :size
      t.string :design_id

      t.timestamps null: false
    end
  end
end
