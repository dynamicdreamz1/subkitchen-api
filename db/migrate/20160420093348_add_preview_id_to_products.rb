class AddPreviewIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :preview_id, :string
  end
end
