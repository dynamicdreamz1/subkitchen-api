describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:order) { create(:order, user: nil, total_cost: 100) }
  let(:params){ { payment_type: 'stripe',
                  stripe_token:  stripe_helper.generate_card_token,
                  full_name: 'full name',
                  address: 'address',
                  city: 'city',
                  zip: 'zip',
                  region: 'region',
                  country: 'country',
                  email: 'test@example.com' } }

  describe '/api/v1/orders/:uuid/payment' do

    context 'valid' do

      before(:each) do
        post "/api/v1/orders/#{order.uuid}/payment", params
        order.reload
      end

      it 'should create stripe payment' do
        expect(order.payment).not_to be_nil
      end

      it 'should be success' do
        expect(response).to have_http_status(:success)
      end

      it 'should change payment status' do
        expect(order.payment.payment_status).to eq('completed')
      end

      it 'should change order purchased' do
        expect(order.purchased).to be_truthy
      end

      it 'should change order state' do
        expect(order.active).to be_falsey
      end

      it 'should add address and email to order' do
        expect(order.full_name).to eq('full name')
        expect(order.address).to eq('address')
        expect(order.city).to eq('city')
        expect(order.zip).to eq('zip')
        expect(order.region).to eq('region')
        expect(order.country).to eq('country')
        expect(order.email).to eq('test@example.com')
      end
    end

    context 'with time freeze' do

      before(:each) do
        @new_time = Time.local(2008, 9, 1, 12, 0, 0)
        Timecop.freeze(@new_time)

        post "/api/v1/orders/#{order.uuid}/payment", params
        order.reload
      end

      it 'should set order purchased at' do
        expect(order.purchased_at).to eq(@new_time)
      end
    end
  end
end