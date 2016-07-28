class ArtistConfirmationPreview < ActionMailer::Preview
  def confirm_email
    user = User.first
    ArtistConfirmation.notify(user.email)
  end
end
