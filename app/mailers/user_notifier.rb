class UserNotifier < ApplicationMailer
  def set_new_password(user)
    @user = user
    @reminder_url = "https://localhost:3000/api/v1/set_new_password?token=#{@user.password_reminder_token}"

    mail to: @user.email, subject: 'Set new password'
  end

  def confirm_email(user)
    @user = user
    @confirmation_url = "https://localhost:3000/api/v1/confirm_email?token=#{@user.confirm_token}"

    mail to: @user.email, subject: 'Confirm Your Email'
  end
end