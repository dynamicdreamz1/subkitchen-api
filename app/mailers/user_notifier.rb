class UserNotifier < ApplicationMailer
  def sign_in(user)
    @user = user
    @reminder_url = "https://#{ENV['MAILGUN_DOMAIN']}/sign_in?token=#{@user.password_reminder_token}"

    mail to: @user.email, subject: 'Cloud Team sign in'
  end
end
