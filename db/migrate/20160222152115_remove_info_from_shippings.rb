class RemoveInfoFromShippings < ActiveRecord::Migration
  def change
    remove_column :shippings, :info, :string
  end
end
