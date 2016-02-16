require 'rails_helper'

RSpec.describe UserNotifier, type: :mailer do
  describe 'sign_in' do
    let(:user) { create(:user) }
    let(:mail) { UserNotifier.sign_in(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Cloud Team sign in')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = "https://#{ENV['MAILGUN_DOMAIN']}/sign_in?token=#{user.password_reminder_token}"
      expect(mail.body.parts.first.body.encoded).to be_include(url)
    end
  end
end
