module Orders
  class Api < Grape::API
    helpers do
      def find_or_create_order(uuid)
        if uuid.blank?
          if current_user
            Order.find_or_create_by(user_id: current_user.id, state: :active)
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
          IncrementOrderItem.new(item).call
        else
          OrderItem.create!(product_id: params.product_id, order_id: order.id)
        end
        order
      end

      desc 'remove item from order'
      params do
        requires :order_item_id, type: Integer
      end
      delete 'item' do
        item = OrderItem.find(params.order_item_id)
        if item
          item.quantity > 1 ? DecrementOrderItem.new(item).call : item.destroy
        else
          status :unprocessable_entity
        end
      end

      desc 'return payment link to paypal'
      params do
        requires :return_path, type: String
        requires :uuid, type: String
      end
      get 'checkout' do
        order = Order.find_by(uuid: params.uuid)
        payment = Payment.create!(payable_id: order.id, payable_type: order.class.name)
        if order
          if CheckOrderItems.new(order).call
            { url: PaypalPayment.new(payment, params.return_path).call }
          else
            UpdateOrderItems.new(order).call
          end
        else
          status :unprocessable_entity
        end
      end
    end
  end
end