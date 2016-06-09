class AddSalesCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sales_count, :integer, default: 0
  end
end
