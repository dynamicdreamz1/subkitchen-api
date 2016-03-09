class AddPaymentTypeAndPaymentTokenToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_type, :string
    add_column :payments, :payment_token, :string
  end
end
