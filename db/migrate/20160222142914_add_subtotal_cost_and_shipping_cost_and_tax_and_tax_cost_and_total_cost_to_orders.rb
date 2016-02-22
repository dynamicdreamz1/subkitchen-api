class AddSubtotalCostAndShippingCostAndTaxAndTaxCostAndTotalCostToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :subtotal_cost, :decimal, precision: 8, scale: 2
    add_column :orders, :shipping_cost, :decimal, precision: 8, scale: 2
    add_column :orders, :tax, :decimal, precision: 4, scale: 2
    add_column :orders, :tax_cost, :decimal, precision: 8, scale: 2
    add_column :orders, :total_cost, :decimal, precision: 8, scale: 2
  end
end
