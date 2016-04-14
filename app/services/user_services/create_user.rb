class CreateUser
  def call
    create_user
  end

  private

  def initialize(params)
    @params = params
  end

  def create_user
    User.new(
      name: @params.name,
      password: @params.password,
      password_confirmation: @params.password_confirmation,
      email: @params.email,
      artist: @params.artist,
      handle: create_handle(@params.name)
    )
  end

  def create_handle(name)
    name.to_s.parameterize
  end
end
