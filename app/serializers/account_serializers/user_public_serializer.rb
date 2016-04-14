class UserPublicSerializer
  def as_json(options = {})
    data = {
      user: { id: user.id,
              name: user.name,
              image_url: image_url,
              handle: user.handle,
              company: user.company } }

    if include_sensitive_data
      data[:user][:email] = user.email
      data[:user][:artist] = user.artist
      data[:user][:status] = user.status
      data[:user][:auth_token] = user.auth_token
    end

    data[:errors] = user.errors.to_h if user.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :user, :include_sensitive_data

  def initialize(user, include_sensitive_data = false)
    @user = user
    @include_sensitive_data = include_sensitive_data
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
