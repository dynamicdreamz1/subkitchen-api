describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }


  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end


  describe '/api/v1/payments' do
    it 'should create stripe payment' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)

      post "/api/v1/orders/#{order.uuid}/payment", {payment_type: 'stripe', stripe_token:  stripe_helper.generate_card_token}

      expect(order.payment).not_to be_nil
    end

    it 'should be success' do
      order = create(:order, user: user)
      product = create(:product)
      create(:order_item, order: order, product: product)

      post "/api/v1/orders/#{order.uuid}/payment", {payment_type: 'stripe', stripe_token:  stripe_helper.generate_card_token}

      expect(response).to have_http_status(:success)
    end

    it 'should change order status' do
      order = create(:order, user: user, total_cost: 100)
      product = create(:product)
      create(:order_item, order: order, product: product)

      post "/api/v1/orders/#{order.uuid}/payment", {payment_type: 'stripe', stripe_token:  stripe_helper.generate_card_token}

      expect(order.payment.payment_status).to eq('completed')
    end

    it 'should raise error when amount zero' do
      order = create(:order, user: user, total_cost: 0)

      post "/api/v1/orders/#{order.uuid}/payment", {payment_type: 'stripe', stripe_token:  stripe_helper.generate_card_token}

      expect(json['errors']).to eq({'base'=>['Invalid positive integer']})
    end
  end
end
