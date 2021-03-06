require 'rails_helper'

RSpec.describe AccountResetPassword, type: :mailer do
  describe 'set_new_password' do
    let(:user) { create(:user) }
    let(:mail) do
      options = { password_reminder_token: user.password_reminder_token,
                  name: user.name }
      AccountResetPassword.notify(user.email, options)
    end

    it 'renders the headers' do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = File.join(Figaro.env.frontend_host, 'new_password', user.password_reminder_token)
      expect(mail.encoded).to be_include(url)
    end
  end
end
