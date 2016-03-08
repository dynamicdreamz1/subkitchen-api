class AddConfigImageIdToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :config_image_id, :string
  end
end
