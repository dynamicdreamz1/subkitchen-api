class UserPublicSerializer
  def as_json(options = {})
    data = { name: user.name,
      image_url: image_url,
      artist: user.artist,
      handle: user.handle,
      status: user.status,
      company: user.company,
      email: user.email }

    data[:errors] = user.errors if user.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def image_url
    if user.profile_image_url
      Figaro.env.app_host.to_s + Refile.attachment_url(user, :profile_image, :fill, 200, 200, format: :png)
    else
      if user.provider == 'facebook' && user.uid
        return "https://graph.facebook.com/#{user.uid}/picture?width=200"
      end
      nil
    end
  end
end
