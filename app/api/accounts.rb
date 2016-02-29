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

      desc 'upload profile image'
      params do
        requires :image, type: File
      end
      post 'profile_image' do
        authenticate!
        image = ActionDispatch::Http::UploadedFile.new(params.image)
        if CheckProfileImageSize.new(image.tempfile.path, params.image.type).call
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
        if CheckShopBannerSize.new(banner.tempfile.path, params.banner.type).call
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
