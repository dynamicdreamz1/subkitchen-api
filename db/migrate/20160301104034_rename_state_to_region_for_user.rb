class RenameStateToRegionForUser < ActiveRecord::Migration
  def change
    rename_column :users, :state, :region
  end
end
