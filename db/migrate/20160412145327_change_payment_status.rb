class ChangePaymentStatus < ActiveRecord::Migration
  def change
    remove_column :payments, :payment_status, :string
    add_column :payments, :payment_status, :integer, default: 2
  end
end
