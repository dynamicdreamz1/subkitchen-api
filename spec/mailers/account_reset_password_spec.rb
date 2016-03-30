require 'rails_helper'

RSpec.describe AccountResetPassword, type: :mailer do
  describe 'set_new_password' do
    let(:user) { create(:user) }
    let(:mail) { AccountResetPassword.notify_single(user.email, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Set new password')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = "#{Figaro.env.frontend_host}/new_password/#{user.password_reminder_token}"
      expect(mail.body.raw_source).to be_include(url)
    end
  end
end
