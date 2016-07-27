require 'rails_helper'

RSpec.describe PaymentConfirmationMailer, type: :mailer do
  describe 'confirm_email' do
    let(:user) { create(:user) }
    let(:order) { create(:order, purchased: true, purchased_at: DateTime.now) }
    let(:invoice) { create(:invoice, order: order) }
    let(:mail) do
      options = { order: order, invoice: invoice }
      PaymentConfirmationMailer.notify(user.email, options)
    end

    it 'renders the headers' do
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'should have attachment' do
      expect(mail.attachments.size).to eq(2)
      expect(mail.attachments.last.content_type).to eq('application/pdf')
    end
  end
end
