class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :order_id
      t.string :line_1
      t.string :line_2
      t.string :line_3
      t.string :line_4
      t.string :line_5
      t.string :line_6
      t.timestamps null: false
    end
  end
end
