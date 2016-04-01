class AccountResetPasswordPreview < ActionMailer::Preview
  def reset_password
    user = User.first
    options = { password_reminder_token: user.password_reminder_token,
                name: user.name }
    AccountResetPassword.notify(user.email, options)
  end
end
