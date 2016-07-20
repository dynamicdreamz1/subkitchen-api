class AddPaypalUrlToOrders < ActiveRecord::Migration
  def change
		add_column :orders, :paypal_url, :string, default: nil
	end
end
