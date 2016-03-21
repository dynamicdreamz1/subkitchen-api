require 'rails_helper'

RSpec.describe DesignerNotifier, type: :mailer do
  describe 'notify designer' do
    before do
      create(:config, name: 'tax', value: '6')
      create(:config, name: 'shipping_cost', value: '7.00')
      create(:config, name: 'shipping_info', value: 'info')
      AdminUser.destroy_all
      @designer_email = 'designer@example.com'
      @product = create(:product)
      @products = [@product]
      @mail = DesignerNotifier.notify_designer(@products, @designer_email )
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq('New products are waiting for design')
      expect(@mail.to).to eq([@designer_email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      expect(@mail.body.parts.first.body.encoded).to be_include("Product ID: <a href=\"#{Figaro.env.frontend_host}admin/products/#{@product.id}\">#{@product.id}")
    end
  end
end
