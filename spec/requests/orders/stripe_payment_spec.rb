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
  let(:order) { create(:order, user: user, total_cost: 100) }
  let(:item) { create(:order_item, order: order, product: product) }

  before(:all) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
  end


  describe '/api/v1/orders/:uuid/payment' do
    describe 'GET' do
      it 'should get serialized order' do
        get "/api/v1/orders/#{order.uuid}/payment"

        expect(response).to have_http_status(:success)
        expect(response).to match_response_schema('checkout')
      end

      it 'should update items before checkout' do
        order = create(:order, user: nil)
        product = create(:product, price: 12)
        product.update(price: 12)
        create(:order_item, order: order, product: product, price: 12)
        product = create(:product, price: 30)
        product.update(price: 30)
        create(:order_item, order: order, product: product, price: 30)
        UpdateOrder.new(order).call
        DeleteProduct.new(product).call

        get "/api/v1/orders/#{order.uuid}/payment"

        expect(json['deleted_items']).not_to be_nil
        expect(json['order']['subtotal'].to_f).to eq(12.0)
        expect(response).to match_response_schema('checkout')
      end
    end

    describe 'POST' do
      it 'should create stripe payment' do
        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(order.payment).not_to be_nil
      end

      it 'should be success' do
        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(response).to have_http_status(:success)
      end

      it 'should change payment status' do
        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(order.payment.payment_status).to eq('completed')
      end

      it 'should change order purchased' do
        post "/api/v1/orders/#{order.uuid}/payment", params

        order.reload
        expect(order.purchased).to be_truthy
      end

      it 'should set order purchased at' do
        new_time = Time.local(2008, 9, 1, 12, 0, 0)
        Timecop.freeze(new_time)

        post "/api/v1/orders/#{order.uuid}/payment", params

        order.reload
        expect(order.purchased_at).to eq(new_time)
      end

      it 'should change order state' do
        post "/api/v1/orders/#{order.uuid}/payment", params

        order.reload
        expect(order.active).to be_falsey
      end

      it 'should raise error when amount zero' do
        order = create(:order, user: user, total_cost: 0)

        post "/api/v1/orders/#{order.uuid}/payment", params

        expect(json['errors']).to eq({'base'=>['Invalid positive integer']})
      end

      it 'should add address and email to order' do
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

      it 'should return error when parameters wrong' do
        no_token_params = {payment_type: 'stripe',
                  full_name: 'full name',
                  address: 'address',
                  city: 'city',
                  zip: 'zip',
                  region: 'region',
                  country: 'country',
                  email: 'test@example.com'}
        post "/api/v1/orders/#{order.uuid}/payment", no_token_params

        expect(json['errors']).to eq({'base'=>['invalid payment parameters!']})
      end

      context 'designer notifications' do

        it 'should notify designer when product has no design' do
          create(:config, name: 'designers', value: 'designer@example.com')
          create(:order_item, order: order, product: create(:product, design_id: nil))

          expect do
            post "/api/v1/orders/#{order.uuid}/payment", params

          end.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'should not notify designer when all products have design' do
          create(:config, name: 'designers', value: 'designer@example.com')
          create(:order_item, order: order, product: create(:product, design_id: '123'))

          expect do
            post "/api/v1/orders/#{order.uuid}/payment", params

          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end

        it 'should not notify designer when no designers' do
          create(:config, name: 'designers', value: '')
          create(:order_item, order: order, product: create(:product, design_id: nil))

          expect do
            post "/api/v1/orders/#{order.uuid}/payment", params


          end.to change { ActionMailer::Base.deliveries.count }.by(0)
        end
      end
    end
  end
end