require 'concerns/email_key_replacer'

class AccountResetPassword < ApplicationMailer
  KEYS = { 'REMINDER_URL' => ' (required) - url for user to reset forgotten password',
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
    { 'reminder_url' => "#{Figaro.env.frontend_host}new_password/#{options[:password_reminder_token]}",
      'user_name' => options[:name] }
  end
end
