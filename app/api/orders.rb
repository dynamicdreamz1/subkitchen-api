module Orders
  class Api < Grape::API
    helpers do
      def find_or_create_order(uuid)
        if uuid.blank?
          if current_user
            Order.find_or_create_by(user_id: current_user.id, active: true)
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
      resources :item do
        desc 'add item to order'
        params do
          requires :product_id, type: Integer
          requires :size, type: String
          requires :quantity, type: Integer
          optional :uuid, type: String
        end
        post do
          order = find_or_create_order(params.uuid)
          item = OrderItem.find_by(product_id: params.product_id, order_id: order.id, size: params[:size])
          if item
            OrderItemQuantity.new(item, params.quantity).call
          else
            CreateOrderItem.new(params.product_id, order, params).call
          end
          UpdateOrder.new(order).call
          OrderSerializer.new(order.reload).as_json
        end

        desc 'remove item from order'
        delete ':id' do
          item = OrderItem.find_by(id: params.id)
          if item
            order = item.order
            item.destroy
          else
            error!({errors: {base: ['cannot find item']}}, 422)
          end
          UpdateOrder.new(order).call
          OrderSerializer.new(order.reload).as_json
        end
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
            error!({errors: {base: ['some of the items had to be removed because the products does not exist anymore']}}, 422)
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
        if order
          if CheckOrderItems.new(order).call
            CheckoutSerializer.new(order).as_json
          else
            UpdateOrderItems.new(order).call
          end
        else
          error!({errors: {base: ['cannot find order']}}, 422)
        end
      end
    end
  end
end