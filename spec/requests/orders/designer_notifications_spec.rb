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
    context 'with designers' do
      before(:each) do
        create(:config, name: 'designers', value: 'designer@example.com')
      end

      context 'with no design products' do
        before(:each) do
          create(:order_item, order: order, product: create(:product, design_id: nil))
          post "/api/v1/orders/#{order.uuid}/payment", params
        end

        it 'should notify' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context 'with design products' do
        before(:each) do
          create(:order_item, order: order, product: create(:product, design_id: '1234'))
          post "/api/v1/orders/#{order.uuid}/payment", params
        end

        it 'should not notify' do
          expect(ActionMailer::Base.deliveries.count).to eq(0)
        end
      end
    end

    context 'with no designers' do
      before(:each) do
        create(:config, name: 'designers', value: '')
        create(:order_item, order: order, product: create(:product, design_id: nil))
        post "/api/v1/orders/#{order.uuid}/payment", params
      end

      it 'should not notify designer when no designers' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
