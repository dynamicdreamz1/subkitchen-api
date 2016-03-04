class RemoveStatusFromPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :status, :string
  end
end
