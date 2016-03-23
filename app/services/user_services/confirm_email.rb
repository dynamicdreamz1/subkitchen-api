class ConfirmEmail
  def call
    confirm_email
  end

  private

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def confirm_email
    user.update_attribute(:email_confirmed, true)
    user.regenerate_confirm_token
  end
end
