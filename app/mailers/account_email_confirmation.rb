require 'concerns/email_key_replacer'

class AccountEmailConfirmation < ApplicationMailer
  KEYS = { 'CONFIRMATION_URL' =>  ' (required) - url to confirm email from registration form',
          'USER_NAME' => " - user's name" }
  include EmailKeyReplacer

  def notify(email, options = {})
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(options))

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  private

  def values(options)
    { 'confirmation_url' => "#{Figaro.env.frontend_host}confirm_email/#{options[:confirmation_token]}",
      'user_name' => options[:name] }
  end
end
