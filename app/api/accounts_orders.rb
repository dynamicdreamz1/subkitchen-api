module AccountsOrders
  class Api < Grape::API
    resource :orders do
      desc 'get orders of current user'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 5
      end
      get do
        authenticate!
        orders = Order.user(current_user.id).page(params.page).per(params.per_page)
        OrderListSerializer.new(orders).as_json
      end

      desc 'get order of current user by id'
      get '/:id' do
        authenticate!
        order = Order.find_by!(id: params.id, user_id: current_user.id)
        CheckoutSerializer.new(order).as_json
      end
    end
  end
end
