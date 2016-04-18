class ChangeColorColumn < ActiveRecord::Migration
  def change
    remove_column :colors, :color_image_id, :string
    add_column :colors, :color_value, :string
  end
end
