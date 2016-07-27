class ArtistConfirmation < ApplicationMailer
  KEYS = {}

  def notify(email)
    template = EmailTemplate.where(name: self.class.name.to_s).first
    content = template.content

    mail(to: email, subject: template.subject ) do |format|
      format.html { render html: content.html_safe }
    end
  end
end
