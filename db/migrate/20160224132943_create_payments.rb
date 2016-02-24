class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :payable, polymorphic: true
      t.timestamps null: false
    end
    add_index :payments, [:payable_id, :payable_type]
  end
end
