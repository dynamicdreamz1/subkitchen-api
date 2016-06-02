require 'concerns/email_key_replacer'

class AccountEmailConfirmation < ApplicationMailer
  KEYS = { 'CONFIRMATION_URL' => ' (required) - url to confirm email from registration form',
           'USER_NAME' => " - user's name" }.freeze
  include EmailKeyReplacer

  def notify(email, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  private

  def values(options)
    { 'confirmation_url' => confirmation_url(options[:confirmation_token]),
      'user_name' => options[:name] }
  end

  def confirmation_url(confirmation_token)
    File.join(Figaro.env.frontend_host, 'confirm_email', confirmation_token)
  end
end
