describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:order) { create(:order, user: user) }
  let(:order_item) { create(:order_item, order: order, product: product) }
  let(:params) do
    { return_path: '',
      payment_type: 'paypal',
      full_name: 'full name',
      address: 'address',
      city: 'city',
      zip: 'zip',
      region: 'region',
      country: 'country',
      email: 'test@example.com' }
  end

  context 'with valid params' do
    before(:each) do
      post "/api/v1/orders/#{order.uuid}/payment", params
      @payment = Payment.find_by(payable: order)
    end

    it 'should return payment link to paypal' do
      expect(json['url']).to eq(PaypalPaymentRequest.new(@payment, '').call)
      expect(response).to match_response_schema('paypal')
      expect(response).to have_http_status(:success)
    end
  end

  context 'with deleted products' do
    before(:each) do
      create(:order_item, order: order, product: product)
      DeleteProduct.new(product).call

      post "/api/v1/orders/#{order.uuid}/payment", params
    end

    it 'should return deleted items' do
      expect(json['deleted_items']).to_not be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'after payment is created' do
    before(:each) do
      changed_params = {
        return_path: '',
        payment_type: 'paypal',
        full_name: 'changed',
        address: 'changed',
        city: 'changed',
        zip: 'changed',
        region: 'changed',
        country: 'changed',
        email: 'changed@example.com' }
      post "/api/v1/orders/#{order.uuid}/payment", params
      post "/api/v1/orders/#{order.uuid}/payment", changed_params
      order.reload
    end

    it 'should not update order address' do
      expect(response).to have_http_status(:not_found)

      expect(order.full_name).not_to eq('changed')
      expect(order.address).not_to eq('changed')
      expect(order.city).not_to eq('changed')
      expect(order.zip).not_to eq('changed')
      expect(order.region).not_to eq('changed')
      expect(order.country).not_to eq('changed')
      expect(order.email).not_to eq('changed@example.com')
    end
  end

  context 'with invlid params' do
    before(:each) do
      no_return_path = { payment_type: 'paypal',
                         full_name: 'full name',
                         address: 'address',
                         city: 'city',
                         zip: 'zip',
                         region: 'region',
                         country: 'country',
                         email: 'test@example.com' }
      post "/api/v1/orders/#{order.uuid}/payment", no_return_path
    end

    it 'should return error' do
      expect(json['errors']).to eq('base' => ['invalid payment parameters!'])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
