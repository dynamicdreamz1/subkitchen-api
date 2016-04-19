class AddLocationAndWebsiteAndBioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :location, :string, default: ''
    add_column :users, :website, :string, default: ''
    add_column :users, :bio, :string, default: ''
  end
end
