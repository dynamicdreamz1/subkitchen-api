class RenameLikesCountToProductLikes < ActiveRecord::Migration
  def change
		rename_column :users, :likes_count, :product_likes
	end
end
