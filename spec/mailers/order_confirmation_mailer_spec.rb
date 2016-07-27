require 'rails_helper'

RSpec.describe OrderConfirmationMailer, type: :mailer do
  describe 'confirm_email' do
    let(:user) { create(:user) }
    let(:order) { create(:purchased_order_with_items) }
    let(:mail) do
      options = { order: order }
      OrderConfirmationMailer.notify(user.email, options)
    end

    it 'renders the headers' do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'should have attachment' do
      expect(mail.attachments.size).to eq(1)
    end
  end
end
