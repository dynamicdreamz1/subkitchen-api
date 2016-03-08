class AddInputTypeToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :input_type, :string
  end
end
