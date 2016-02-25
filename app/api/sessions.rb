module Sessions
  class Api < Grape::API
    resource :sessions do
      desc 'authenticate user'
      params do
        requires :email, type: String
        requires :password, type: String
      end
      post 'login' do
        user = User.find_by(email: params.email)
        if user.authenticate(params.password)
          user
        else
          status :unprocessable_entity
        end
      end

      desc 'register new user'
      params do
        requires :email, type: String
        requires :password, type: String
        requires :password_confirmation, type: String
        requires :name, type: String
        requires :artist, type: Boolean
      end
      post 'register' do
        user =  User.new(
            name: params.name,
            password: params.password,
            password_confirmation: params.password_confirmation,
            email: params.email,
            artist: params.artist
        )
        if user.save
          UserNotifier.confirm_email(user).deliver_later
          user
        else
          status :unprocessable_entity
        end
      end

      desc 'confirm email'
      params do
        requires :confirm_token, type: String
      end
      post 'confirm_email' do
        user = User.with_confirm_token(params.confirm_token)
        if user
          user.update_attribute(:email_confirmed, true)
          user.regenerate_confirm_token
          user
        else
          status :unprocessable_entity
        end
      end

      desc 'change password'
      params do
        requires :current_password, type: String
        requires :password, type: String
        requires :password_confirmation, type: String
      end
      post 'change_password' do
        authenticate!
        if current_user.authenticate(params.current_password)
          current_user.update!(password: params.password, password_confirmation: params.password_confirmation)
        else
          status :unprocessable_entity
        end
      end

      desc 'receive email with link to set new password'
      params do
        requires :email, type: String
      end
      post 'forgot_password' do
        user = User.find_by(email: params.email)
        if user
          UserNotifier.set_new_password(user).deliver_later
          user.password_reminder_expiration = DateTime.now + 2.hours
          user.save
        else
          status :unprocessable_entity
        end
      end

      desc 'set new password through link'
      params do
        requires :token, type: String
      end
      get 'set_new_password' do
        if User.with_reminder_token(params.token)
          status :ok
        else
          status :unprocessable_entity
        end
      end

      params do
        requires :token, type: String
        requires :password, type: String
        requires :password_confirmation, type: String
      end
      post 'set_new_password' do
        user = User.with_reminder_token(params.token)
        if user
          user.update!(password: params.password, password_confirmation: params.password_confirmation, password_reminder_expiration: nil)
          user.regenerate_password_reminder_token
        else
          status :unprocessable_entity
        end
      end

      desc 'return verify user link to paypal'
      params do
        requires :return_path, type: String
      end
      get 'verify_profile' do
        authenticate!
        payment = Payment.create(payable_id: current_user.id, payable_type: current_user.class.name)
        { url: PaypalUserVerification.new(payment, params.return_path).call }
      end
    end
  end
end
