class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :orders, :first_name, :full_name
  end
end
