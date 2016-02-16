module Sessions
  class Api < Grape::API
    resource :sessions do
      desc 'authenticate user'
      params do
        requires :token, type: String
      end
      post do
        user = User.with_reminder_token(params.token).first
        fail ActiveRecord::RecordNotFound unless user
        user
      end

      desc 'send authentication url to user'
      params do
        optional :email, type: String
      end
      post '/sign_in' do
        user = User.find_or_create_by(email: params[:email])
        status(:unprocessable_entity) unless user
        SignIn.new(user).call
        nil
      end

      resource :oauth do
        desc 'facebook connect'
        params do
          requires :access_token
        end
        post 'facebook' do
          user = OmniauthRegister.new(:facebook, params.access_token).call
          error!('', :unprocessable_entity) unless user && user.persisted?
          status(200)
          user
        end
      end
    end
  end
end
