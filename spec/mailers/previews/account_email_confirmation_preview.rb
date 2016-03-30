class AccountEmailConfirmationPreview < ActionMailer::Preview
  def confirm_email
    user = User.first
    AccountEmailConfirmation.notify(user)
  end
end
