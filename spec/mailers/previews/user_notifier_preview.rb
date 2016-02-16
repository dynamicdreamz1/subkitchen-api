# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
class UserNotifierPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_notifier/sign_in
  def sign_in(user)
    UserNotifier.sign_in(user)
  end

  def invitation(team, email)
    UserNotifier.invitation(team, email)
  end
end
