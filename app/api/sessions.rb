module Sessions
  class Api < Grape::API
    resource :sessions do
      desc 'authenticate user'
      params do
        requires :email, type: String
        requires :password, type: String
      end
      post do
        user = User.find_by(email: params.email)
        if user.authenticate(params.password)
          user
        else
          status :unprocessable_entity
        end
      end
    end
  end
end
