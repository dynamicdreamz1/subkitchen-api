class ApplicationMailer < ActionMailer::Base
  default from: "contact@#{ENV['MAILGUN_DOMAIN'] || 'cloud-team.herokuapp.com'}"
  layout 'mailer'
end
