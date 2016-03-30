class SendNewPasswordLink
  def call
    send_link
  end

  private

  def initialize(user)
    @user = user
  end

  def send_link
    AccountResetPassword.notify(@user).deliver_later
    @user.password_reminder_expiration = DateTime.now + 2.hours
    @user.save
    @user
  end
end