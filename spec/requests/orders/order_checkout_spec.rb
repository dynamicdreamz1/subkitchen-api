describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  describe 'CHECKOUT' do
    it 'should checkout' do
      order = create(:order, user: nil)
      product = create(:product)
      create(:order_item, order: order, product: product)
      create(:order_item, order: order, product: product)
      params = { uuid: order.uuid }

      get '/api/v1/orders/checkout', params

      expect(response).to match_response_schema('checkout')
    end

    it 'should update items before checkout' do
      order = create(:order, user: nil)
      product = create(:product)
      create(:order_item, order: order, product: product)
      params = { uuid: order.uuid }
      DeleteResource.new(product).call

      get '/api/v1/orders/checkout', params

      expect(response).to match_response_schema('checkout')
    end
  end
end
