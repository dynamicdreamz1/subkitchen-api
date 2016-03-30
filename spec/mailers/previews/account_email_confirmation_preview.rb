class AccountEmailConfirmationPreview < ActionMailer::Preview
  def confirm_email
    user = User.first
    AccountEmailConfirmation.notify_single(user.email, user)
  end
end
