class SetNewPassword
  def call
    set_new_password
  end

  private

  def initialize(user, params)
    @user = user
    @params = params
  end

  def set_new_password
    @user.password = @params.password
    @user.password_confirmation = @params.password_confirmation
    @user.password_reminder_expiration = nil
    if @user.save
      @user.regenerate_password_reminder_token
    end
    @user
  end
end