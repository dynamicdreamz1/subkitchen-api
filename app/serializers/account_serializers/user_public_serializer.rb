class UserPublicSerializer
  def as_json(options = {})
    data = {
      user: { id: user.id,
              name: user.name,
							image_url: user.profile_image || image_url,
							banner_url: user.shop_banner,
              handle: user.handle,
              bio: user.bio,
              company: user.company,
              products_count: user.products.published_all.count,
              likes_count: user.likes.count }
    }

    if include_sensitive_data
      data[:user][:email] = user.email
      data[:user][:location] = user.location
      data[:user][:website] = user.website
      data[:user][:bio] = user.bio
			data[:user][:artist] = user.artist
			data[:user][:current_account_state] = user.current_account_state
			data[:user][:earnings_overall] = user.earnings_count
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
		if user.provider == 'facebook' && user.uid
			return "https://graph.facebook.com/#{user.uid}/picture?width=200&height=200"
		end
		nil
	end
end
