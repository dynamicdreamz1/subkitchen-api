require 'concerns/email_key_replacer'

class AccountResetPassword < ApplicationMailer
  KEYS = {'REMINDER_URL' => ' (required) - url for user to reset forgotten password',
          'USER_NAME' => " - user's name"}
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
    if user
      token = user.password_reminder_token
      user_name = user.name
    else
      token = 'password_reminder_token'
      user_name = 'TestName'
    end
    {
        'reminder_url' => "#{Figaro.env.frontend_host}/new_password/#{token}",
        'user_name' => user_name
    }
  end
end
