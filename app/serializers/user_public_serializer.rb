class UserPublicSerializer
  def as_json(options = {})
    data = { name: user.name,
      image_url: image_url,
      email: user.email }

    data[:company] = user.company if user.artist

    data[:errors] = user.errors if user.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def image_url
    if user.provider == 'facebook' && user.uid
      return "https://graph.facebook.com/#{user.uid}/picture?width=200"
    end
    nil
  end
end
