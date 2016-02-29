class AddImagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_image_id, :string
    add_column :users, :shop_banner_id, :string
  end
end
