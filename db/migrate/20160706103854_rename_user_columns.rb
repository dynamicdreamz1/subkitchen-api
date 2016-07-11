class RenameUserColumns < ActiveRecord::Migration
  def change
		rename_column :users, :profile_image_id, :profile_image
		rename_column :users, :shop_banner_id, :shop_banner
  end
end
