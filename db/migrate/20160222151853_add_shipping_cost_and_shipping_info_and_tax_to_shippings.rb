class AddShippingCostAndShippingInfoAndTaxToShippings < ActiveRecord::Migration
  def change
    add_column :shippings, :shipping_cost, :decimal, precision: 8, scale: 2
    add_column :shippings, :shipping_info, :string
    add_column :shippings, :tax, :decimal, precision: 4, scale: 2
  end
end
