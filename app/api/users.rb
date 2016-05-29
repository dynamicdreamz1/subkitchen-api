module Users
  class Api < Grape::API
    resources :users do
      desc 'get current user'
      get '/current' do
        authenticate!
        current_user
      end

      desc 'update current user'
      put ':id' do
        authenticate!
        UpdateUser.new(current_user, params).call
        send_notification = current_user.changes[:email]
        if current_user.save
          options = { confirmation_token: current_user.confirm_token, name: current_user.name }
          AccountEmailConfirmation.notify(current_user.email, options).deliver_later if send_notification
        else
          status(:unprocessable_entity)
        end
        current_user
      end

      desc 'return user by id'
      get ':id' do
        UserPublicSerializer.new(User.find(params[:id]))
      end

      desc 'return user by handle'
      params do
        requires :handle, type: String
      end
      get '/' do
        UserPublicSerializer.new(User.where(handle: params[:handle]).first!)
      end
    end
  end
end
