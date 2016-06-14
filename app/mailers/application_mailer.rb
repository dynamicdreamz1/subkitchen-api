class ApplicationMailer < ActionMailer::Base
  default from: "contact@#{ENV['MAILGUN_DOMAIN'] || 'cloud-team.herokuapp.com'}"
  layout 'mailer'

  before_filter :add_inline_attachment!

  private
  def add_inline_attachment!
    attachments.inline['logo.png'] = File.read(File.join(Rails.root,'app','assets','images','mailer','header.png'))
  end
end
