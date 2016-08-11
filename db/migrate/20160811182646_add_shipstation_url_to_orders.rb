class AddShipstationUrlToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipstation_url, :string
  end
end
