class AddUuidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
