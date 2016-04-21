class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :description
      t.string :code
      t.decimal :discount, precision: 8, scale: 2
      t.datetime :redeemed
      t.datetime :valid_from
      t.datetime :valid_until
      t.boolean :percentage, default: false
      t.integer :redemption_limit, default: 0
      t.timestamps null: false
    end
  end
end
