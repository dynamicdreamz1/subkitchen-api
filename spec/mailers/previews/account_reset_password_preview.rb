class AccountResetPasswordPreview < ActionMailer::Preview
  def reset_password
    user = User.first
    AccountResetPassword.notify_single(user.email, user)
  end
end
