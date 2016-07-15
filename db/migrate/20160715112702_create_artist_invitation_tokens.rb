class CreateArtistInvitationTokens < ActiveRecord::Migration
  def change
    create_table :artist_invitation_tokens do |t|
			t.integer :user_id
			t.uuid :uuid, default: 'uuid_generate_v4()'
      t.timestamps null: false
    end
  end
end
