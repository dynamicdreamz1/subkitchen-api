describe Products::Api, type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  describe 'orders/add_item' do
    it 'should add item to order' do
      post '/api/v1/orders/add_item', { product_id: product.id }, auth_header_for(user)

      order = Order.find_by(user_id: user.id, state: :active)
      expect(order).not_to be_nil
      expect(order.order_items.size).to eq(1)
    end

    it 'should increment quantity' do
      order = create(:order, user: user)
      create(:order_item, product: product, order: order)

      post '/api/v1/orders/add_item', { product_id: product.id }, auth_header_for(user)

      order = Order.find_by(user_id: user.id, state: :active)
      expect(order.order_items.first.quantity).to eq(2)
    end
  end

  describe 'orders/remove_item' do
    it 'should remove item from order' do
      order = create(:order, user: user)
      create(:order_item, order: order, product: product)

      delete '/api/v1/orders/remove_item', { product_id: product.id }, auth_header_for(user)

      item = OrderItem.find_by(order: order, product: product)
      expect(item).to be_nil
    end

    it 'should decrement' do
      order = create(:order, user: user)
      create(:order_item, order: order, product: product)
      create(:order_item, order: order, product: product)

      delete '/api/v1/orders/remove_item', { product_id: product.id }, auth_header_for(user)

      item = OrderItem.find_by(order: order, product: product)
      expect(item.quantity).to eq(1)
    end
  end

  describe 'orders/checkout' do
    it 'should return payment link to paypal' do
      order = create(:order, user: user)
      get '/api/v1/orders/checkout', { return_path: '', notify_path: '/payment_notifications' }, auth_header_for(user)

      expect(response.body).to eq(order.paypal_payment_url('', '/payment_notifications').to_json)
    end

    it 'should check if product exists' do
      order = create(:order, user: user)
      product = create(:product)
      item = create(:order_item, order: order, product: product)
      product.delete_product

      get '/api/v1/orders/checkout', { return_path: '', notify_path: '/payment_notifications' }, auth_header_for(user)

      expect(response.body).to eq([item].to_json)
    end
  end
end
