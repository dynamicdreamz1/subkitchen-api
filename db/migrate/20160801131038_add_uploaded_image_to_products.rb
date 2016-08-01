class AddUploadedImageToProducts < ActiveRecord::Migration
  def change
    add_column :products, :uploaded_image, :string
  end
end
