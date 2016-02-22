class AddSizeChartToProductTemplate < ActiveRecord::Migration
  def change
    add_column :product_templates, :size_chart_id, :string
  end
end
