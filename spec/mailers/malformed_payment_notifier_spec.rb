require 'rails_helper'

RSpec.describe MalformedPaymentNotifier, type: :mailer do
  describe 'malformed payment' do
    before(:each) do
      @admin = create(:admin_user)
      @payment = create(:payment, payment_status: 'malformed')
      @mail = MalformedPaymentNotifier.notify(@admin.email, @payment)
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq('Malformed payment')
      expect(@mail.to).to eq([@admin.email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      expect(@mail.body.raw_source).to be_include("href=\"#{Figaro.env.frontend_host}admin/payments/#{@payment.id}\">#{@payment.id}")
    end
  end
end
