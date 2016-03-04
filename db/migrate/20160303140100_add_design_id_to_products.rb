class AddDesignIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :design_id, :string
  end
end
