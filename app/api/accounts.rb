module Accounts
  class Api < Grape::API
    resource :account do
      desc 'updates user info'
      params do
        optional :name, type: String
        optional :email, type: String
        optional :handle, type: String
      end
      put ':id' do
        authenticate!
        user = User.find_by(id: params.id)
        if user
          UpdateUser.new(user, params).call
        else
          status :unprocessable_entity
        end
      end
    end
  end
end