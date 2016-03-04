class AddPaymentStatusToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_status, :string, default: 'pending'
  end
end
