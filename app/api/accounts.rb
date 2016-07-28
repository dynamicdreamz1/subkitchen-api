module Accounts
  class Api < Grape::API
    desc 'array of countries and their codes'
    get 'iso_countries' do
			IsoCountryCodes.for_select
    end

    resources :account do
      before do
        authenticate!
      end

      desc 'get current user'
      get do
        authenticate!
        current_user
      end

      desc 'user verification'
      params do
        optional :return_path, type: String
        optional :has_company, type: Boolean
        optional :handle, type: String
        optional :company_name, type: String
        optional :address, type: String
        optional :city, type: String
        optional :zip, type: String
        optional :region, type: String
        optional :country, type: String
      end
      post 'verification' do
        result = VerifyArtist.new(current_user, params).call
        return result if result
        status(:unprocessable_entity)
        current_user
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
        CompanyAddress.new(current_user, params).call
        current_user
			end
		end

		resources :account do

			desc 'simple user verification. See SK-317'
			params do
				optional :uuid, type: String
				optional :email, type: String
				optional :password, type: String
				optional :password_confirmation, type: String
				optional :name, type: String
				optional :handle, type: String, default: nil
				optional :artist, type: Boolean, default: true
			end
			post 'simple_verification' do
				if params.uuid
					user = CreateVerifiedArtist.new(params, current_user).call
					status(:unprocessable_entity) unless user.valid?
					user
				elsif current_user
					authenticate!
					VerifyArtistSimple.new(current_user).call
					current_user
				else
					user = CreateUser.new(params).call
					status(:unprocessable_entity) unless user.valid?
					user
				end
			end
		end
  end
end
