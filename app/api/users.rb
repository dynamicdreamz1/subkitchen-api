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
          options = { confirmation_token: current_user.confirm_token,
                      name: current_user.name }
          AccountEmailConfirmation.notify(current_user.email, options).deliver_later if send_notification
        else
          status(:unprocessable_entity)
        end
        current_user
      end

      desc 'return user by id or handle'
      get ':id' do
        user = User.where(handle: params[:id]).first || User.find(params[:id])
        UserPublicSerializer.new(user).as_json
      end
    end
  end
end
