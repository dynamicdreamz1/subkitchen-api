module Accounts
  class Api < Grape::API
    desc 'array of countries and their codes'
    get 'iso_countries' do
      IsoCountryCodes.for_select
    end

    resources :account do
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
        authenticate!
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
        authenticate!
        CompanyAddress.new(current_user, params).call
        current_user
      end

      desc 'upload profile image'
      params do
        requires :image, type: File
      end
      post 'profile_image' do
        authenticate!
        image = ActionDispatch::Http::UploadedFile.new(params.image)
        current_user.profile_image = image
        current_user.valid?
        if current_user.errors[:profile_image].blank?
          current_user.errors.delete(:profile_image)
          current_user.save(validate: false)
          current_user.reload
        else
          status(:unprocessable_entity)
        end
        UserPublicSerializer.new(current_user)
      end

      desc 'upload shop banner'
      params do
        requires :banner, type: File
      end
      post 'shop_banner' do
        authenticate!
        banner = ActionDispatch::Http::UploadedFile.new(params.banner)
        if current_user.artist
          current_user.shop_banner = banner
          if current_user.valid?
            current_user.save
            data = { shop_banner_url: current_user.shop_banner_url }
            data[:errors] = current_user.errors if current_user.errors.any?
            data
          else
            error!({ errors: current_user.errors.messages }, 422)
          end
        else
          error!({ errors: { base: ['user must be an artist'] } }, 422)
        end
      end
    end
  end
end
