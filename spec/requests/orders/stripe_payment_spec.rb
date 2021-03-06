describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before {
    StripeMock.start
    create(:config, name: 'designers', value: nil)
  }
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
    context 'order confirmation mailer' do
      it 'should send order confirmation email' do
        order = create(:purchased_order_with_items)
        delivery = double
        expect(delivery).to receive(:deliver_later).with(no_args)

        expect(OrderConfirmationMailer).to receive(:notify)
          .with(params[:email], order: order)
          .and_return(delivery)

        post "/api/v1/orders/#{order.uuid}/payment", params
      end
    end

    context 'valid' do
      before(:each) do
        post "/api/v1/orders/#{order.uuid}/payment", params
        order.reload
      end

      it 'should create stripe payment' do
        expect(order.payment).not_to be_nil
        expect(response).to have_http_status(:success)
        expect(order.payment.payment_status).to eq('completed')
        expect(order.purchased).to be_truthy
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
        Timecop.freeze(@new_time) do
          post "/api/v1/orders/#{order.uuid}/payment", params
          order.reload
        end
      end

      it 'should set order purchased at' do
        expect(order.purchased_at).to eq(@new_time)
      end
    end
  end
end
