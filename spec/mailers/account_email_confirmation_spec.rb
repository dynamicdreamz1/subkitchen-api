require 'rails_helper'

RSpec.describe AccountEmailConfirmation, type: :mailer do
  describe 'confirm_email' do
    let(:user) { create(:user) }
    let(:mail) { AccountEmailConfirmation.notify(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Confirm Your Email')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = "#{Figaro.env.frontend_host}/confirm_email/#{user.confirm_token}"
      expect(mail.body.raw_source).to be_include(url)
    end
  end
end
