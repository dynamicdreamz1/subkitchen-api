class AccountEmailConfirmation < ApplicationMailer

  KEYS = ['CONFIRMATION_URL']

  KEYS.each do |key|
    define_method("replace_#{key.downcase}") do |content, values|
      content.gsub!(key, values[key.downcase])
    end
  end

  def self.notify(user)
    notify_single(user.email, user).deliver_later
  end

  def notify_single(email, user=nil)
    template = EmailTemplate.where(name: 'user_account_email_confirmation').first
    content = template.content
    token = user.confirm_token || 'confirm_token'
    values = { 'confirmation_url' => "#{Figaro.env.frontend_host}/confirm_email/#{token}" }

    KEYS.each do |key|
      send("replace_#{key.downcase}", content, values)
    end

    mail to: email,
         body: content,
         content_type: 'text/html',
         subject: template.subject
  end
end
