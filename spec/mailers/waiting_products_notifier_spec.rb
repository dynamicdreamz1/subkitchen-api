require 'rails_helper'

RSpec.describe WaitingProductsNotifier, type: :mailer do
  describe 'notify designer' do
    before(:each) do
      @designer_email = 'designer@example.com'
      @product = create(:product)
      @products = [@product]
      @mail = WaitingProductsNotifier.notify(@designer_email, @products)
    end

    it 'renders the headers' do
      expect(@mail.subject).to eq('New products are waiting for design')
      expect(@mail.to).to eq([@designer_email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      expect(@mail.body.raw_source).to be_include("<a href=\"#{Figaro.env.frontend_host}admin/products/#{@product.id}\">#{@product.name}")
    end
  end
end
