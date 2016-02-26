class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :company_name, default: ''
      t.string :address, default: ''
      t.string :city, default: ''
      t.string :zip, default: ''
      t.string :region, default: ''
      t.string :country, default: ''
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
