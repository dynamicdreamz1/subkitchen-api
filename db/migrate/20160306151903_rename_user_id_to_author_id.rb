class RenameUserIdToAuthorId < ActiveRecord::Migration
  def change
    rename_column :products, :user_id, :author_id
  end
end
