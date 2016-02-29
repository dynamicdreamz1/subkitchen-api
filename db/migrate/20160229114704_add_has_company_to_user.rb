class AddHasCompanyToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_company, :boolean, default: false
  end
end
