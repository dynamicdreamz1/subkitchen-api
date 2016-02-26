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
          UpdateUser.new(user, params).update_user
        else
          status :unprocessable_entity
        end
      end

      desc 'updates shipping info'
      params do
        requires :first_name, type: String
        requires :last_name, type: String
        requires :address, type: String
        requires :city, type: String
        requires :zip, type: String
        requires :region, type: String
        requires :country, type: String
        optional :phone, type: String
      end
      post 'address' do
        authenticate!
        if current_user
          UpdateUser.new(current_user, params).update_address
        else
          status :unprocessable_entity
        end
      end
    end
  end
end