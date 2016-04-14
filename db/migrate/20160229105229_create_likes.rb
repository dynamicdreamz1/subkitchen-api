class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.belongs_to :likeable, polymorphic: true
      t.integer :user_id
      t.timestamps null: false
    end
    add_index :likes, [:likeable_id, :likeable_type]
  end
end
