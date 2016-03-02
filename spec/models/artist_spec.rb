require 'rails_helper'

RSpec.describe User, type: :model do
  let(:artist){create(:user, artist: true, status: 'verified')}

  before do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  context 'sales_counter' do
    let(:product){create(:product, author: artist)}
    let(:order){create(:order)}

    it 'has incremented sales counter when user buys product' do
      OrderItem.create!(order: order, product: product, quantity: 3)
      payment = create(:payment, payable: order)
      expect do
        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesCounter.drain
      end.to change{artist.sales_count}.by(3)
    end
  end
end
