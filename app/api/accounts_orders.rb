module AccountsOrders
  class Api < Grape::API

    resource :account do
      resource :orders do

        desc 'orders of user'
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 30
        end
        get do
          authenticate!
          orders = Order.where(user: current_user).page(params.page).per(params.per_page)
          OrderListSerializer.new(orders).as_json
        end

        desc 'view specific order of user'
        get ':uuid' do
          authenticate!
          order = Order.find_by!(uuid: params.uuid)
          CheckoutSerializer.new(order).as_json
        end
      end
    end
  end
end
