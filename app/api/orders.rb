module Orders
  class Api < Grape::API
    helpers do
      def find_or_create_order(uuid)
        if uuid.blank?
          if current_user
            Order.find_or_create_by(user_id: current_user.id)
          else
            Order.create
          end
        else
          order = Order.where(uuid: uuid).first
          order.user ||= current_user
          order.save
          order
        end
      end
    end

    resources :orders do
      desc 'add item to order'
      params do
        requires :product_id, type: Integer
        optional :uuid, type: String
      end
      post 'item' do
        order = find_or_create_order(params.uuid)
        item = OrderItem.find_by(product_id: params.product_id, order_id: order.id)
        if item
          OrderItemQuantity.new(item).increment
        else
          product = Product.find_by(id: params.product_id)
          OrderItem.create!(product_id: product.id, order_id: order.id)
        end
        UpdateOrder.new(order).call
        order.reload
      end

      desc 'remove item from order'
      params do
        requires :order_item_id, type: Integer
      end
      delete 'item' do
        item = OrderItem.find(params.order_item_id)
        order = item.order
        if item
          item.quantity > 1 ? OrderItemQuantity.new(item).decrement : item.destroy
        else
          error!({errors: {base: ['cannot find item']}}, 422)
        end
        UpdateOrder.new(order).call
        order.reload
      end

      desc 'return payment link to paypal'
      params do
        requires :return_path, type: String
        requires :uuid, type: String
      end
      get 'paypal_payment_url' do
        order = Order.find_by(uuid: params.uuid)
        payment = Payment.create!(payable_id: order.id, payable_type: order.class.name)
        if order
          if CheckOrderItems.new(order).call
            { url: PaypalPayment.new(payment, params.return_path).call }
          else
            UpdateOrderItems.new(order).call
          end
        else
          error!({errors: {base: ['cannot find order']}}, 422)
        end
      end

      desc 'checkout order'
      params do
        requires :uuid, type: String
      end
      get 'checkout' do
        order = Order.find_by(uuid: params.uuid)
        status :unprocessable_entity unless order
        CheckoutSerializer.new(order).as_json
      end
    end
  end
end