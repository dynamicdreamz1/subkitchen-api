class AddUuidToLike < ActiveRecord::Migration
  def change
    add_column :likes, :uuid, :uuid, default: 'uuid_generate_v4()'
    add_index :likes, [:uuid, :likeable_id, :likeable_type], :unique => true
  end
end
