describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    @params = { return_path: '',
                payment_type: 'paypal',
                full_name: 'full name',
                address: 'address',
                city: 'city',
                zip: 'zip',
                region: 'region',
                country: 'country',
                email: 'test@example.com'}
  end

  describe 'PAYPAL' do
    it 'should return payment link to paypal' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)

      post "/api/v1/orders/#{order.uuid}/payment", @params

      payment = Payment.find_by(payable: order)
      expect(json['url']).to eq(PaypalPayment.new(payment, '').call)
      expect(response).to match_response_schema('paypal')
    end

    it 'should check if product exists' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)
      DeleteProduct.new(product).call

      post "/api/v1/orders/#{order.uuid}/payment", @params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['deleted_items']).to_not be_empty
    end
  end
end
