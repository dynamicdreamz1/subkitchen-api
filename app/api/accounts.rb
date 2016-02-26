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

      desc 'add company address'
      params do
        requires :company_name, type: String
        requires :address, type: String
        requires :city, type: String
        requires :zip, type: String
        requires :region, type: String
        requires :country, type: String
      end
      post 'verification' do
        authenticate!
        artist = User.find_by(id: current_user.id)
        if artist
          CreateCompanyAddress.new(artist, params).call
        else
          status :unprocessable_entity
          artist
        end
      end

      desc 'return verify user link to paypal'
      params do
        requires :return_path, type: String
      end
      get 'paypal_verification_url' do
        authenticate!
        payment = Payment.create(payable_id: current_user.id, payable_type: current_user.class.name)
        { url: PaypalUserVerification.new(payment, params.return_path).call }
      end
    end
  end
end