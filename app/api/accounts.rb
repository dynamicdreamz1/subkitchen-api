module Accounts
  class Api < Grape::API
    desc 'array of countries and their codes'
    get 'iso_countries' do
      IsoCountryCodes.for_select
    end

    resource :account do
      desc 'update email'
      params do
        optional :email
      end
      put '/email' do
        authenticate!
        if current_user.update(email: params.email)
          UserNotifier.confirm_email(current_user).deliver_later
        else
          status :unprocessable_entity
        end
        current_user
      end

      desc 'update name'
      params do
        optional :name
      end
      put '/name' do
        authenticate!
        unless current_user.update(name: params.name)
          status :unprocessable_entity
        end
        current_user
      end

      desc 'update handle'
      params do
        optional :handle
      end
      put '/handle' do
        authenticate!
        unless current_user.update(handle: params.handle)
          status :unprocessable_entity
        end
        current_user
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
        UpdateUser.new(current_user, params).update_address
      end


      desc 'user verification'
      params do
        requires :return_path, type: String
        requires :has_company, type: Boolean
        optional :company_name, type: String
        optional :address, type: String
        optional :city, type: String
        optional :zip, type: String
        optional :region, type: String
        optional :country, type: String
      end
      post 'verification' do
        authenticate!
        VerifyArtist.new(current_user, params).call || error!(current_user, :unprocessable_entity)
      end

      desc 'update company address'
      params do
        requires :company_name, type: String
        requires :address, type: String
        requires :city, type: String
        requires :zip, type: String
        requires :region, type: String
        requires :country, type: String
      end
      post 'company_address' do
        authenticate!
        CompanyAddress.new(current_user, params).call
        current_user
      end
    end
  end
end
