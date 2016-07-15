class CreateVerifiedArtist
  def call
		token = find_artist_invitation_token
    user = current_user || create_user
		update_user(user)
		update_artist_invitation_token(token, user)
		user
  end

  private

	attr_reader :params
	attr_accessor :current_user

  def initialize(params, current_user)
    @params = params
		@current_user = current_user
  end

  def create_user
    User.create(
      name: params.name,
      password: params.password,
      password_confirmation: params.password_confirmation,
      email: params.email,
      handle: params.handle
    )
	end

	def update_user(user)
		user.handle = user.name unless user.handle
		user.artist = true
		user.status = 1
		user.save
	end

	def find_artist_invitation_token
		ArtistInvitationToken.find_by!(uuid: params.uuid, user_id: nil)
	end

	def update_artist_invitation_token(token, user)
		token.update(user: user) if user.artist && user.verified?
	end
end
