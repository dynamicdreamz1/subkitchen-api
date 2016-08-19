class AddPreviewFilenameToProduct < ActiveRecord::Migration
  def change
    add_column :products, :preview_filename, :string
  end
end
