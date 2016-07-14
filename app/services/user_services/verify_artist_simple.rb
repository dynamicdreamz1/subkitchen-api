class VerifyArtistSimple
	include Grape::DSL::InsideRoute

  def call
		status 422 unless update_user
  end

  private

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def update_user
    user.update(artist: true, handle: user.name)
  end
end
