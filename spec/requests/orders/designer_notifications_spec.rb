describe Payments::Api, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:order) { create(:order, total_cost: 100) }
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
        it 'should notify' do
          create(:order_item, order: order, product: create(:product, design_id: nil))

          delivery = double
          expect(delivery).to receive(:deliver_later).with(no_args)

          expect(WaitingProductsNotifier).to receive(:notify)
            .with(Config.designers.strip.split(';'), products: order.products)
            .and_return(delivery)

          post "/api/v1/orders/#{order.uuid}/payment", params
        end
      end

      context 'with design products' do
        it 'should not notify' do
          create(:order_item, order: order, product: create(:product, design_id: '1234'))

          expect(WaitingProductsNotifier).to_not receive(:notify)

          post "/api/v1/orders/#{order.uuid}/payment", params
        end
      end
    end

    context 'with no designers' do
      it 'should not notify designer when no designers' do
        create(:config, name: 'designers', value: '')
        create(:order_item, order: order, product: create(:product, design_id: nil))

        expect(WaitingProductsNotifier).to_not receive(:notify)

        post "/api/v1/orders/#{order.uuid}/payment", params
      end
    end
  end
end
