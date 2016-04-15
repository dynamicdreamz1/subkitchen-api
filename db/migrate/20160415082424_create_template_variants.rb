class CreateTemplateVariants < ActiveRecord::Migration
  def change
    create_table :template_variants do |t|
      t.string :name
      t.string :template_color_image_id

      t.integer :color_id
      t.integer :product_template_id

      t.timestamps null: false
    end
  end
end
