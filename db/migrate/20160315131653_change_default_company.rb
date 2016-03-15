class ChangeDefaultCompany < ActiveRecord::Migration
  def change
    change_column :companies, :company_name, :string, default: ''
    change_column :companies, :address, :string, default: ''
    change_column :companies, :region, :string, default: ''
    change_column :companies, :zip, :string, default: ''
    change_column :companies, :country, :string, default: ''
    change_column :companies, :city, :string, default: ''
  end
end
