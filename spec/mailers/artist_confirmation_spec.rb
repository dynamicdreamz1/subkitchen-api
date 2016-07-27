require 'rails_helper'

RSpec.describe ArtistConfirmation, type: :mailer do
  describe 'confirm_email' do
    let(:user) { create(:user) }
    let(:mail) do
      ArtistConfirmation.notify(user.email)
    end

    it 'renders the headers' do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = 'http://sublimation.kitchen'
      expect(mail.encoded).to be_include(url)
    end
  end
end
