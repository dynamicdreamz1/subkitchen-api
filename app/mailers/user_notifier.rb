class UserNotifier < ApplicationMailer
  def set_new_password(user)
    @user = user
    @reminder_url = "#{Figaro.env.frontend_host}/new_password/#{@user.password_reminder_token}"

    mail to: @user.email, subject: 'Set new password'
  end

  def confirm_email(user)
    @user = user
    @confirmation_url = "#{Figaro.env.frontend_host}/confirm_email/#{@user.confirm_token}"

    mail to: @user.email, subject: 'Confirm Your Email'
  end
end
