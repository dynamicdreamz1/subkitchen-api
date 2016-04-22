class CreateNewsletterReceivers < ActiveRecord::Migration
  def change
    create_table :newsletter_receivers do |t|
      t.string :email
      t.timestamps null: false
    end
  end
end
