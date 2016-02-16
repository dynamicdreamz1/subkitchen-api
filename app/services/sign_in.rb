class SignIn
  def call
    regenerate_remind_token!
    UserNotifier.sign_in(user).deliver_later
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def regenerate_remind_token!
    user.password_reminder_expiration = Time.zone.now + 12.hours
    user.password_reminder_token = User.generate_unique_secure_token(:password_reminder_token)
    user.save!
  end
end
