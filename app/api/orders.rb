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
      post 'add_item' do
        order = find_or_create_order(params.uuid)

        item = OrderItem.find_by(product_id: params.product_id, order_id: order.id)
        if item
          item.increment
        else
          OrderItem.create!(product_id: params.product_id, order_id: order.id)
        end
        order
      end

      desc 'remove item from order'
      params do
        requires :product_id, type: Integer
      end
      delete 'remove_item' do
        item = OrderItem.find_by(product_id: params.product_id)
        if item
          item.quantity > 1 ? item.decrement : item.destroy
        else
          status :unprocessable_entity
        end
      end

      desc 'return payment link to paypal'
      params do
        requires :return_path, type: String
      end
      get 'checkout' do
        authenticate!
        order = Order.find_by(user_id: current_user.id, state: :active)
        payment = Payment.create(payable_id: order.id, payable_type: order.class.name)
        if order
          if order.order_items_exist?
            { url: PaypalPayment.new(payment, params.return_path).call }
          else
            order.update_order
          end
        else
          status :unprocessable_entity
        end
      end
    end
  end
end