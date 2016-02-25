require 'rails_helper'

RSpec.describe UserNotifier, type: :mailer do
  describe 'set_new_password' do
    let(:user) { create(:user) }
    let(:mail) { UserNotifier.set_new_password(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Set new password')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = "https://localhost:3000/api/v1/set_new_password?token=#{user.password_reminder_token}"
      expect(mail.body.parts.first.body.encoded).to be_include(url)
    end
  end

  describe 'confirm_email' do
    let(:user) { create(:user) }
    let(:mail) { UserNotifier.confirm_email(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm Your Email')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = "https://localhost:3000/api/v1/confirm_email?token=#{user.confirm_token}"
      expect(mail.body.parts.first.body.encoded).to be_include(url)
    end
  end
end
