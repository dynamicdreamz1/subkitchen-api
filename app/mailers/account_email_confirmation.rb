require 'concerns/email_key_replacer'

class AccountEmailConfirmation < ApplicationMailer
  KEYS = { 'CONFIRMATION_URL' =>  ' (required) - url to confirm email from registration form',
          'USER_NAME' => " - user's name" }
  include EmailKeyReplacer

  def notify(user)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(user))

    mail to: user.email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  private

  def values(user)
    token = user.try(:confirm_token) || 'confirm_token'
    user_name = user.try(:name) || 'TestName'
    { 'confirmation_url' => "#{Figaro.env.frontend_host}/confirm_email/#{token}",
      'user_name' => user_name }
  end
end
