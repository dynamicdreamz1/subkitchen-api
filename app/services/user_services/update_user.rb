class UpdateUser
  def call
    update_user if params.user
  end

  private

  attr_accessor :user
  attr_reader :params


  def initialize(user, params)
    @params = params
    @user = user
  end

  def update_user
    user.name =  params.user.name,
    user.email =  params.user.email,
    user.handle =  params.user.handle,
    user.location =  params.user.location,
    user.website =  params.user.website,
    user.bio =  params.user.bio,
    user
  end
end
