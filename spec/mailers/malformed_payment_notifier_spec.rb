require 'rails_helper'

RSpec.describe MalformedPaymentNotifier, type: :mailer do
  describe 'malformed payment' do
    before(:each) do
      @admin = create(:admin_user)
      @payment = create(:payment, payment_status: 'malformed')
      @mail = MalformedPaymentNotifier.notify(@admin.email, payment_id: @payment.id)
    end

    it 'renders the headers' do
      expect(@mail.to).to eq([@admin.email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = File.join(Figaro.env.frontend_host, 'admin/payments', @payment.id.to_s)
      expect(@mail.body.raw_source).to be_include("href=\"#{url}\">#{@payment.id}")
    end
  end
end
