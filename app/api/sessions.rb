module Sessions
  class Api < Grape::API

    helpers do
      def match?(password, confirmation)
        password == confirmation
      end
    end

    resource :sessions do
      desc 'authenticate user'
      params do
        requires :email, type: String
        requires :password, type: String
      end
      post 'login' do
        user = User.find_by!(email: params.email)
        if user.authenticate(params.password)
          user
        else
          error!({errors: {base: ['invalid email or password']}}, 422)
        end
      end

      desc 'register new user'
      params do
        optional :email, type: String
        optional :password, type: String
        optional :password_confirmation, type: String
        optional :name, type: String
        optional :artist, type: Boolean, default: false
      end
      post 'register' do
        user = CreateUser.new(params).call
        if user.save
          UserNotifier.confirm_email(user).deliver_later
        else
          status :unprocessable_entity
        end
        user
      end

      desc 'confirm email'
      params do
        requires :confirm_token, type: String
      end
      post 'confirm_email' do
        user = User.with_confirm_token(params.confirm_token).first
        if user
          ConfirmEmail.new(user).call
          user
        else
          error!({errors: {base: ['invalid confirmation token']}}, 422)
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
        if match?(params.password, params.password_confirmation)
          if current_user.authenticate(params.current_password)
            current_user.update!(password: params.password,
                                 password_confirmation: params.password_confirmation)
            current_user
          else
            error!({errors: {base: ['invalid password']}}, 422)
          end
        else
          error!({errors: {base: ['password and password confirmation does not match']}}, 422)
        end
      end

      desc 'receive email with link to set new password'
      params do
        requires :email, type: String
      end
      post 'forgot_password' do
        user = User.find_by!(email: params.email)
        SendNewPasswordLink.new(user).call
      end

      desc 'set new password through link'
      params do
        optional :token, type: String
        optional :password, type: String
        optional :password_confirmation, type: String
      end
      post 'set_new_password' do
        user = User.with_reminder_token(params.token).first
        if match?(params.password, params.password_confirmation)
          if user
            SetNewPassword.new(user, params).call
            user
          else
            error!({errors: {base: ['invalid or expired reminder token']}}, 422)
          end
        else
          error!({errors: {base: ['password and password confirmation does not match']}}, 422)
        end
      end
    end
  end
end
