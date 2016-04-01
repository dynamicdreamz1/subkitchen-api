class AccountEmailConfirmationPreview < ActionMailer::Preview
  def confirm_email
    user = User.first
    options = {confirmation_token: user.confirm_token, name: user.name}
    AccountEmailConfirmation.notify(user.email, options)
  end
end
