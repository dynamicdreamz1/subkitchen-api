class PromoterSerializer
  def as_json(options = {})
    data = {
      id: user.id,
      name: user.name,
      first_name: user.first_name,
      last_name: user.last_name,
      followers_count: 0,
      artist: user.artist,
      image_url: user.profile_image || image_url,
      handle: user.handle
    }

    { promoter: data }.as_json(options)
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def image_url
		if user.provider == 'facebook' && user.uid
			return "https://graph.facebook.com/#{user.uid}/picture?width=200&height=200"
		end
		nil
  end
end
