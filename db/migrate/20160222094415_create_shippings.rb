class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.string :info
      t.timestamps null: false
    end
  end
end
