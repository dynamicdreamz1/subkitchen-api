module Orders
  class Api < Grape::API
    resources :orders do
      desc 'add item to order'
      params do
        requires :product_id, type: Integer
      end
      post 'add_item' do
        authenticate!
        order = Order.find_or_create_by(user_id: current_user.id, state: :active)
        item = OrderItem.find_by(product_id: params.product_id, order_id: order.id)
        if item
          item.increment
        else
          OrderItem.create!(product_id: params.product_id, order_id: order.id)
        end
      end

      desc 'remove item from order'
      params do
        requires :product_id, type: Integer
      end
      delete 'remove_item' do
        authenticate!
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
        requires :notify_path, type: String
      end
      get 'checkout' do
        authenticate!
        order = Order.find_by(user_id: current_user.id, state: :active)
        if order.order_items_exist?
          if order
            order.paypal_payment_url(params.return_path, params.notify_path)
          else
            status :unprocessable_entity
          end
        else
          order.update_order
        end
      end
    end
  end
end