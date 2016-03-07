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
        params do
          requires :uuid, type: String
        end
        delete ':id' do
          order = Order.find_by!(uuid: params.uuid)
          item = order.order_items.find_by(id: params.id)
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

      desc 'get current order or create new'
      params do
        optional :uuid, type: String
      end
      get do
        order = find_or_create_order(params.uuid)
        OrderSerializer.new(order).as_json
      end

      desc 'return payment link to paypal'
      params do
        requires :return_path, type: String
        requires :uuid, type: String
      end
      get 'paypal_payment_url' do
        order = Order.find_by(uuid: params.uuid)
        if order
          unless CheckOrderItems.new(order).call
            UpdateOrderItems.new(order).call
            error!({errors: {base: ['some of the items had to be removed because the products does not exist anymore']}}, 422)
          end
          CheckoutByPayPal.new(order, params).call || error!({errors: {base: ['already paid']}}, 422)
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
