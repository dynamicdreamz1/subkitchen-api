class AddLikesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :likes, :integer, default: 0
  end
end
