describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }


  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:params) {{payment_type: 'stripe',
                 stripe_token:  stripe_helper.generate_card_token,
                 full_name: 'full name',
                 address: 'address',
                 city: 'city',
                 zip: 'zip',
                 region: 'region',
                 country: 'country',
                 email: 'test@example.com'}}

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end


  describe '/api/v1/orders/:uuid/payment' do
    describe 'GET' do
      it 'should get serialized order' do
        order = create(:order, user: user)
        product = create(:product)
        create(:order_item, order: order, product: product)

        get "/api/v1/orders/#{order.uuid}/payment"

        expect(response).to have_http_status(:success)
        expect(response).to match_response_schema('checkout')
      end

      it 'should update items before checkout' do
        order = create(:order, user: nil)
        product = create(:product)
        create(:order_item, order: order, product: product)
        params = { uuid: order.uuid }
        DeleteResource.new(product).call

        get "/api/v1/orders/#{order.uuid}/payment"

        expect(json['deleted_items']).not_to be_nil
        expect(response).to match_response_schema('checkout')
      end
    end

    describe 'POST' do
      it 'should create stripe payment' do
        order = create(:order, user: user)
        product = create(:product)
        create(:order_item, order: order, product: product)

        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(order.payment).not_to be_nil
      end

      it 'should be success' do
        order = create(:order, user: user)
        product = create(:product)
        create(:order_item, order: order, product: product)

        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(response).to have_http_status(:success)
      end

      it 'should change order status' do
        order = create(:order, user: user, total_cost: 100)
        product = create(:product)
        create(:order_item, order: order, product: product)

        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(order.payment.payment_status).to eq('completed')
      end

      it 'should raise error when amount zero' do
        order = create(:order, user: user, total_cost: 0)

        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(json['errors']).to eq({'base'=>['Invalid positive integer']})
      end

      it 'should add address and email to order' do
        order = create(:order, user: user, total_cost: 100)
        product = create(:product)
        create(:order_item, order: order, product: product)

        post "/api/v1/orders/#{order.uuid}/payment", params

        order.reload
        expect(order.full_name).to eq('full name')
        expect(order.address).to eq('address')
        expect(order.city).to eq('city')
        expect(order.zip).to eq('zip')
        expect(order.region).to eq('region')
        expect(order.country).to eq('country')
        expect(order.email).to eq('test@example.com')
      end
    end
  end
end
