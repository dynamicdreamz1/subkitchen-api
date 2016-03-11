module Addresses
  class Api < Grape::API
    resource :addresses do
      desc 'get current user address'
      get '/current' do
        authenticate!
        AddressSerializer.new(current_user)
      end

      desc 'save current user address'
      params do
        optional :address, type: Hash do
          optional :first_name, type: String
          optional :last_name, type: String
          optional :address, type: String
          optional :city, type: String
          optional :zip, type: String
          optional :region, type: String
          optional :country, type: String
          optional :phone, type: String
        end
      end
      put '/current' do
        authenticate!
        UpdateUser.new(current_user, params.address).update_address
        AddressSerializer.new(current_user)
      end
    end
  end
end
