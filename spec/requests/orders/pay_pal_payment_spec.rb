describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:order){ create(:order, user: user) }
  let(:order_item){ create(:order_item, order: order, product: product) }

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
      post "/api/v1/orders/#{order.uuid}/payment", @params

      payment = Payment.find_by(payable: order)
      expect(json['url']).to eq(PaypalPayment.new(payment, '').call)
      expect(response).to match_response_schema('paypal')
    end

    it 'should check if product exists' do
      create(:order_item, order: order, product: product)
      DeleteProduct.new(product).call


      post "/api/v1/orders/#{order.uuid}/payment", @params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['deleted_items']).to_not be_empty
    end

    it 'should not update address' do
      changed_params = { return_path: '',
                  payment_type: 'paypal',
                  full_name: 'changed',
                  address: 'changed',
                  city: 'changed',
                  zip: 'changed',
                  region: 'changed',
                  country: 'changed',
                  email: 'test@.com'}

      post "/api/v1/orders/#{order.uuid}/payment", @params

      post "/api/v1/orders/#{order.uuid}/payment", changed_params

      order.reload
      expect(order.full_name).not_to eq('changed')
      expect(order.address).not_to eq('changed')
      expect(order.city).not_to eq('changed')
      expect(order.zip).not_to eq('changed')
      expect(order.region).not_to eq('changed')
      expect(order.country).not_to eq('changed')
      expect(order.email).not_to eq('changed')
    end

    it 'should return error when parameters wrong' do
      no_return_path = {payment_type: 'paypal',
                         full_name: 'full name',
                         address: 'address',
                         city: 'city',
                         zip: 'zip',
                         region: 'region',
                         country: 'country',
                         email: 'test@example.com'}
      post "/api/v1/orders/#{order.uuid}/payment", no_return_path

      expect(json['errors']).to eq({'base'=>['invalid payment parameters!']})
    end
  end
end
