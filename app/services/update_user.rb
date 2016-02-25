class UpdateUser
  def call
    update_email
  end

  private

  def initialize(user, params)
    @params = params
    @user = user
  end

  def update_email
    if @user.artist
      @user.update_attributes(name: @params.name, email: @params.email, handle: @params.handle)
    else
      @user.update_attributes(name: @params.name, email: @params.email)
    end
    UserNotifier.confirm_email(@user).deliver_later if email_changed?(@params.email)
    @user
  end

  def email_changed?(email)
    email != @user.email
  end
end