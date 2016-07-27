require 'concerns/email_key_replacer'

class ArtistConfirmation < ApplicationMailer
  KEYS = { 'LOGO_IMG' => " - logo png file" }.freeze
  include EmailKeyReplacer

  def notify(email, options={})
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    replace_keys(content, values(options))

    mail(to: email, subject: template.subject ) do |format|
      format.html { render html: content.html_safe }
    end
  end

  private

  def values(options)
    { 'logo_img'     => attachments['logo.png'].url }
  end
end
