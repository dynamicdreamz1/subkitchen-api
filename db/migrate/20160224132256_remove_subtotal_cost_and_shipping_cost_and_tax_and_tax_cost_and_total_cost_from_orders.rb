class RemoveSubtotalCostAndShippingCostAndTaxAndTaxCostAndTotalCostFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :subtotal_cost, :decimal, precision: 8, scale: 2
    remove_column :orders, :shipping_cost, :decimal, precision: 8, scale: 2
    remove_column :orders, :tax, :decimal, precision: 4, scale: 2
    remove_column :orders, :tax_cost, :decimal, precision: 8, scale: 2
    remove_column :orders, :total_cost, :decimal, precision: 8, scale: 2
  end
end
