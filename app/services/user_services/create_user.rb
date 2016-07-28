class CreateUser
  def call
    create_user
  end

  private

	attr_reader :params

  def initialize(params)
    @params = params
  end

  def create_user
		NewsletterReceiver.find_or_create_by(email: params.email)
		User.create(
      name: params.name,
      password: params.password,
      password_confirmation: params.password_confirmation,
      email: params.email,
      artist: params.artist,
      handle: params.handle || create_handle(params.name)
    )
  end

  def create_handle(name)
    name.to_s.parameterize
  end
end