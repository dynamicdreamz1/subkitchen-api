module Accounts
  class Api < Grape::API

    desc 'array of countries and their codes'
    get 'iso_countries' do
      IsoCountryCodes.for_select
    end

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
          error!({errors: {base: ['no user with given id']}}, 422)
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
        UpdateUser.new(current_user, params).update_address
      end


      desc 'user verification'
      params do
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
        artist = User.find_by(id: current_user.id, artist: true)
        if params.has_company
          if artist
            CompanyAddress.new(artist, params).create_company
          else
            error!({errors: {base: ['no artist with given id']}}, 422)
          end
        end
        artist.update_attribute(:has_company, params[:has_company])
      end

      desc 'return verify user link to paypal'
      params do
        requires :return_path, type: String
      end
      get 'paypal_verification_url' do
        authenticate!
        payment = Payment.create(payable_id: current_user.id, payable_type: current_user.class.name)
        url = PaypalUserVerification.new(payment, params.return_path).call
        { url: url }
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
        if current_user.company
          CompanyAddress.new(current_user, params).create_company
        else
          CompanyAddress.new(current_user, params).update_company
        end
      end
    end
  end
end