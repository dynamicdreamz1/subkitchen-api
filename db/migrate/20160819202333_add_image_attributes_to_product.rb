class AddImageAttributesToProduct < ActiveRecord::Migration
  def change
    add_column :products, :image_filename, :string
    add_column :products, :image_size, :string
    add_column :products, :image_content_type, :string
  end
end
