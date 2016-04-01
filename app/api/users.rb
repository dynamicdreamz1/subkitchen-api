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
        current_user.name = params.user.name
        current_user.email = params.user.email
        current_user.handle = params.user.handle
        send_notification = current_user.changes[:email]
        if current_user.save
          options = {confirmation_token: current_user.confirm_token, name: current_user.name}
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
    end
  end
end
