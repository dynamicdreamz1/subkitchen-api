class UserNotifier < ApplicationMailer
  def set_new_password(user)
    @user = user
    @reminder_url = "https://localhost:3000/api/v1/set_new_password?token=#{@user.password_reminder_token}"

    mail to: @user.email, subject: 'Set new password'
  end
end