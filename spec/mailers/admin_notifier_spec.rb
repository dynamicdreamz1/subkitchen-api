require 'rails_helper'

RSpec.describe AdminNotifier, type: :mailer do
  describe 'malformed payment' do
    before do
      create(:config, name: 'tax', value: '6')
      create(:config, name: 'shipping_cost', value: '7.00')
      create(:config, name: 'shipping_info', value: 'info')
      AdminUser.destroy_all
      @admin = create(:admin_user)
      @payment = create(:payment, payment_status: 'malformed')
      @mail = AdminNotifier.malformed_payment(@payment, @admin)
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq('Malformed payment')
      expect(@mail.to).to eq([@admin.email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      expect(@mail.body.parts.first.body.encoded).to be_include("Payment ID: #{@payment.id}")
    end
  end
end
