class ChangeCodeColumn < ActiveRecord::Migration
  def change
    change_column :coupons, :code, :string, default: ''
  end
end
