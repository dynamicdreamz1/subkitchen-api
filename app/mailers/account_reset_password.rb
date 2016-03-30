require 'concerns/email_key_replacer'

class AccountResetPassword < ApplicationMailer
  include EmailKeyReplacer

  KEYS = ['REMINDER_URL', 'USER_NAME']

  def self.notify(user)
    notify_single(user.email, user).deliver_later
  end

  def notify_single(email, user=nil)
    template = EmailTemplate.where(name: "#{self.class.name}").first
    content = template.content

    replace_keys(content, values(user))

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end

  def self.keys
    ["REMINDER_URL (required) - url for user to reset forgotten password",
     "USER_NAME - user's name"]
  end

  private

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

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
