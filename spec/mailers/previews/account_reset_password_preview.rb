class AccountResetPasswordPreview < ActionMailer::Preview
  def reset_password
    user = User.first
    AccountResetPassword.notify(user)
  end
end
