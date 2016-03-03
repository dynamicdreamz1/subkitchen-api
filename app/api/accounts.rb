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

      desc 'upload profile image'
      params do
        requires :image, type: File
      end
      post 'profile_image' do
        authenticate!
        image = ActionDispatch::Http::UploadedFile.new(params.image)
        if CheckProfileImageSize.new(params.image).call
          current_user.update(profile_image: image)
          data = { profile_image_url: current_user.profile_image_url }
          data[:errors] = current_user.errors if current_user.errors.any?
          data
        else
          error!({errors: {base: ['image is too small']}}, 422)
        end
      end

      desc 'upload shop banner'
      params do
        requires :banner, type: File
      end
      post 'shop_banner' do
        authenticate!
        banner = ActionDispatch::Http::UploadedFile.new(params.banner)
        if CheckShopBannerSize.new(params.banner).call
          if current_user.artist
            current_user.update(shop_banner: banner)
            data = { shop_banner_url: current_user.shop_banner_url }
            data[:errors] = current_user.errors if current_user.errors.any?
            data
          else
            error!({errors: {base: ['user must be an artist']}}, 422)
          end
        else
          error!({errors: {base: ['image is too small']}}, 422)
        end
      end
    end
  end
end
