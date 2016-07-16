class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
			t.integer :user_id
			t.decimal :value, precision: 8, scale: 2
      t.timestamps null: false
    end
  end
end
