class CreateProductWishes < ActiveRecord::Migration
  def change
    create_table :product_wishes do |t|
      t.integer :user_id
      t.integer :wished_product_id
      t.timestamps null: false
    end
  end
end
