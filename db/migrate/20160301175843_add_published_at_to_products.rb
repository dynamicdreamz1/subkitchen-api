class AddPublishedAtToProducts < ActiveRecord::Migration
  def change
    add_column :products, :published_at, :datetime, default: nil
  end
end
