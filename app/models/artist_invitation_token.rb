class ArtistInvitationToken < ActiveRecord::Base
	belongs_to :user
	validates :user_id,  uniqueness: { allow_nil: true }
end
