module Orders
  class Api < Grape::API
    helpers do
      def find_or_create_order(uuid)
        if uuid.blank?
          if current_user
            Order.find_or_create_by(user_id: current_user.id, active: true, order_status: 'creating')
          else
            Order.create
          end
        else
          order = Order.where(uuid: uuid, active: true, order_status: 'creating').first
          order ||= Order.new
          order.user ||= current_user
          order.save
          order
        end
      end
    end

    desc 'Through6 customer information'
    params do
      requires :order_uuid, type: String
    end
    get 'receipt' do
      order = Order.find_by!(uuid: params.order_uuid)
      OrderAddressSerializer.new(order).as_json
    end

    desc 'Through6 updates'
    params do
      requires :order_uuid, type: String
    end
    get 'track' do
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
          params[:quantity] = params[:quantity].to_i.abs
          order = find_or_create_order(params.uuid)

          error!({ errors: { 'base' => ['cannot change already paid order'] } }, 422) if order.payment
          item = order.order_items.find_by(product_id: params.product_id, order_id: order.id, size: params[:size])
          if item
            OrderItemQuantity.new(item, params.quantity).call
          else
            CreateOrderItem.new(params.product_id, order, params).call
          end
          CalculateOrder.new(order).call
          OrderSerializer.new(order.reload).as_json
        end

        desc 'update item'
        params do
          requires :quantity, type: Integer
          requires :uuid, type: String
        end
        put ':id' do
          params[:quantity] = params[:quantity].to_i.abs
          order = Order.find_by!(uuid: params.uuid)
          item = order.order_items.find(params.id)
          item.update(quantity: params.quantity)
          CalculateOrder.new(order).call
          OrderSerializer.new(order.reload).as_json
        end

        desc 'remove item from order'
        params do
          requires :uuid, type: String
        end
        delete ':id' do
          order = Order.find_by!(uuid: params.uuid)
          item = order.order_items.find(params.id)
          order = item.order
          item.destroy
          CalculateOrder.new(order).call
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
    end
  end
end
