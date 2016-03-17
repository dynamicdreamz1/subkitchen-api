class RemoveHasCompanyFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :has_company, :boolean
  end
end
