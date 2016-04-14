class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :order_id
      t.string :line_1, default: ''
      t.string :line_2, default: ''
      t.string :line_3, default: ''
      t.string :line_4, default: ''
      t.string :line_5, default: ''
      t.string :line_6, default: ''
      t.timestamps null: false
    end
  end
end
