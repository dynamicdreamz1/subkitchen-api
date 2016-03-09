describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  describe 'PAYPAL' do
    it 'should return payment link to paypal' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)

      get '/api/v1/orders/paypal_payment_url', { return_path: '', uuid: order.uuid }

      payment = Payment.find_by(payable: order)
      expect(json['url']).to eq(PaypalPayment.new(payment, '').call)
      expect(response).to match_response_schema('paypal')
    end

    it 'should check if product exists' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)
      DeleteResource.new(product).call

      get '/api/v1/orders/paypal_payment_url', { return_path: '', uuid: order.uuid }

      expect(json['errors']).to eq({'base'=>['some of the items had to be removed because the products does not exist anymore']})
    end
  end
end
