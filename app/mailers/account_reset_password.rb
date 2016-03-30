class AccountResetPassword < ApplicationMailer

  KEYS = ['REMINDER_URL']

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def self.notify(user)
    notify_single(user.email, user).deliver_later
  end

  def notify_single(email, user=nil)
    template = EmailTemplate.where(name: 'customer_account_password_reset').first
    content = template.content
    token = user.password_reminder_token || 'password_reminder_token'
    values = { 'reminder_url' => "#{Figaro.env.frontend_host}/new_password/#{token}" }

    KEYS.each do |key|
      send("replace_#{key.downcase}", content, values)
    end

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end
end
