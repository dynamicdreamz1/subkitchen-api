class OauthRegister
  def call
    respond_to?(provider, true) ? send(provider) : nil
  end

  private

  attr_reader :provider, :access_token

  def initialize(provider, access_token)
    @provider = provider.to_sym
    @access_token = access_token
  end

  def facebook
    profile = Koala::Facebook::API.new(access_token).get_object('me', fields: 'email,name')
    find_or_create_user(provider: :facebook,
                        uid: profile['id'],
                        email: profile['email'],
                        name: profile['name'])
  rescue Koala::Facebook::APIError
    nil
  end

  def find_or_create_user(provider: '', uid: '', email: '', name: '')
    user = User.where(provider: provider, uid: uid).first
    user ||= User.where(email: email).first if email.present?
    user ||= User.new
    user.oauth_registration = true
    user.uid = uid
    user.provider = provider
    user.name ||= name
    user.email ||= email
    if user.password_digest.blank?
      password = SecureRandom.uuid
      user.password = password
      user.password_confirmation = password
    end
    user.save
    user
  end
end
