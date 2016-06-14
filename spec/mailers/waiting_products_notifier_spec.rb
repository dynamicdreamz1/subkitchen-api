require 'rails_helper'

RSpec.describe WaitingProductsNotifier, type: :mailer do
  describe 'notify designer' do
    before(:each) do
      @designer_email = 'designer@example.com'
      @product = create(:product)
      @products = [@product]
      @mail = WaitingProductsNotifier.notify(@designer_email, products: @products)
    end

    it 'renders the headers' do
      expect(@mail.to).to eq([@designer_email])
      expect(@mail.from).to eq(["contact@#{ENV['MAILGUN_DOMAIN']}"])
    end

    it 'renders the body' do
      url = File.join(Figaro.env.frontend_host, 'admin/products', @product.id.to_s)
      expect(@mail.encoded).to be_include("<a href=\"#{url}\">#{@product.name}")
    end
  end
end
