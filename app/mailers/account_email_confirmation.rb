require 'concerns/email_key_replacer'

class AccountEmailConfirmation < ApplicationMailer
  KEYS = { 'CONFIRMATION_URL' => ' (required) - url to confirm email from registration form',
           'USER_NAME' => " - user's name",
           'LOGO_IMG' => " - logo png file" }.freeze
  include EmailKeyReplacer

  def notify(email, options = {})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail(to: email, subject: template.subject ) do |format|
      format.html { render html: content.html_safe }
    end
  end

  private

  def values(options)
    { 'confirmation_url' => confirmation_url(options[:confirmation_token]),
      'user_name'        => options[:name],
      'logo_img'         => attachments['logo.png'].url }
  end

  def confirmation_url(confirmation_token)
    File.join(Figaro.env.frontend_host, 'confirm_email', confirmation_token)
  end
end
