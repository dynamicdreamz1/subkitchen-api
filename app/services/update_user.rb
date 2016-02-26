class UpdateUser
  def update_user
    UserNotifier.confirm_email(@user).deliver_later if email_changed?(@params.email)
    if @user.artist
      @user.update_attributes(name: @params.name, email: @params.email, handle: @params.handle)
    else
      @user.update_attributes(name: @params.name, email: @params.email)
    end
    @user
  end

  def update_address
    @user.update_attributes(
      first_name: @params.first_name,
      last_name: @params.last_name,
      address: @params.address,
      city: @params.city,
      zip: @params.zip,
      region: @params.region,
      country: @params.country,
      phone: @params.phone
    )
    @user
  end

  private

  def initialize(user, params)
    @params = params
    @user = user
  end

  def email_changed?(email)
    email != @user.email
  end
end