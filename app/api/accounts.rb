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
        end
        current_user
      end

      desc 'update name'
      params do
        optional :name
      end
      put '/name' do
        authenticate!
        current_user.update(name: params.name)
        current_user
      end

      desc 'update handle'
      params do
        optional :handle
      end
      put '/handle' do
        authenticate!
        current_user.update(handle: params.handle)
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
        requires :conditions, type: Boolean, default: false
        optional :company_name, type: String
        optional :address, type: String
        optional :city, type: String
        optional :zip, type: String
        optional :region, type: String
        optional :country, type: String
      end
      post 'verification' do
        authenticate!
        if params.conditions
          artist = User.find_by(id: current_user.id, artist: true)
          if artist
            CompanyAddress.new(artist, params).create_company
          else
            error!({errors: {base: ['no artist with given id']}}, 422)
          end
        else
          error!({errors: {conditions: ['must be accepted']}}, 422)
        end
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
