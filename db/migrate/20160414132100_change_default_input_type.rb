class ChangeDefaultInputType < ActiveRecord::Migration
  def change
    change_column :configs, :input_type, :string, default: 'short_text'
  end
end
