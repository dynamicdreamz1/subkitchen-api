describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:order) { create(:order, user: nil, total_cost: 100) }
  let(:params) do
    { payment_type: 'stripe',
      stripe_token:  stripe_helper.generate_card_token,
      full_name: 'full name',
      address: 'address',
      city: 'city',
      zip: 'zip',
      region: 'region',
      country: 'country',
      email: 'test@example.com' }
  end

  describe '/api/v1/orders/:uuid/payment' do
    context 'when amount is zero or less' do
      before(:each) do
        order = create(:order, user: nil, total_cost: 0)
        post "/api/v1/orders/#{order.uuid}/payment", params
      end

      it 'should raise error' do
        expect(json['errors']).to eq('base' => ['Invalid positive integer'])
      end
    end

    context 'with invalid params' do
      before(:each) do
        order = create(:order)
        no_token_params = { payment_type: 'stripe',
                            full_name: 'full name',
                            address: 'address',
                            city: 'city',
                            zip: 'zip',
                            region: 'region',
                            country: 'country',
                            email: 'test@example.com' }
        post "/api/v1/orders/#{order.uuid}/payment", no_token_params
      end

      it 'should return error' do
        expect(json['errors']).to eq('base' => ['invalid payment parameters!'])
      end
    end
  end
end
