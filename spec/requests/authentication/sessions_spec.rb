describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    describe 'LOGIN' do
      it 'should authenticate' do
        user = create(:user)

        post '/api/v1/sessions/login', email: user.email, password: 'password'

        expect(response).to have_http_status(:success)
        expect(json['name']).to eq(user.name)
        expect(json['auth_token']).to eq(user.auth_token)
        expect(response).to match_response_schema('user_public')
      end

      it 'should not authenticate' do
        post '/api/v1/sessions/login', email: 'test@test.test', password: 'password'

        expect(json['errors']).to eq({'base'=>['record not found']})
      end
    end

    describe 'REGISTER' do
      it 'should be able to register' do
        params =  { email: 'test@gmail.com',
                    name: 'test',
                    password: 'password',
                    password_confirmation: 'password',
                    artist: 'false' }

        expect do
          post '/api/v1/sessions/register', params
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response).to match_response_schema('user_public')
      end

      it 'should not be able to register with no password' do
        params =  { email: 'test@gmail.com',
                    name: 'test',
                    password: '',
                    password_confirmation: '',
                    artist: 'false' }

        expect do
          post '/api/v1/sessions/register', params
        end.to change(User, :count).by(0)
      end

      it 'should receive email with confirmation link' do
        params = { email: 'test@gmail.com',
                   name: 'test',
                   password: 'password',
                   password_confirmation: 'password',
                   artist: 'false'
        }
        expect do
          post '/api/v1/sessions/register', params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'CHANGE PASSWORD' do
      it 'should change password' do
        user = create(:user, password: 'password')
        new_params = { current_password: 'password',
                       password: 'newpassword',
                       password_confirmation: 'newpassword' }

        post '/api/v1/sessions/change_password', new_params, auth_header_for(user)

        expect(response).to have_http_status(:success)
        user.reload
        expect(user.authenticate('newpassword')).to be_truthy
        expect(response).to match_response_schema('user_public')
      end

      it 'should not change password when invalid password' do
        user = create(:user, password: 'password')
        new_params = { current_password: 'invalidpassword', password: 'newpassword', password_confirmation: 'newpassword' }

        post '/api/v1/sessions/change_password', new_params, auth_header_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({'base'=>['invalid password']})
      end

      it 'should not change password when password does not match' do
        user = create(:user, password: 'password')
        new_params = { current_password: 'password', password: 'newpassword', password_confirmation: '' }

        post '/api/v1/sessions/change_password', new_params, auth_header_for(user)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({'base'=>['password and password confirmation does not match']})
      end
    end

    describe 'FORGOT PASSWORD' do
      it 'should receive email with link' do
        user = create(:user)

        expect do
          post '/api/v1/sessions/forgot_password', email: user.email
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(response).to match_response_schema('user_public')
      end

      it 'should not receive email with link' do
        expect do
          post '/api/v1/sessions/forgot_password', email: 'invalid@email.com'
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(response).to have_http_status(:not_found)
        expect(json['errors']).to eq({'base'=>['record not found']})
      end

      describe 'SET PASSWORD' do
        it 'should set new password' do
          user = create(:user)
          params = { token: user.password_reminder_token,
                     password: 'newpassword',
                     password_confirmation: 'newpassword' }

          post '/api/v1/sessions/forgot_password', email: user.email
          post '/api/v1/sessions/set_new_password', params

          expect(response).to have_http_status(:success)
          user.reload
          expect(user.authenticate('newpassword')).to be_truthy
          expect(response).to match_response_schema('user_public')
        end

        it 'should not set new password when password does not match' do
          user = create(:user)
          params = { token: user.password_reminder_token,
                     password: 'newpassword',
                     password_confirmation: '' }

          post '/api/v1/sessions/forgot_password', email: user.email
          post '/api/v1/sessions/set_new_password', params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to eq({'base'=>['password and password confirmation does not match']})
        end

        it 'should not set new password when token expired' do
          user = create(:user)
          params = { token: user.password_reminder_token,
                     password: 'newpassword',
                     password_confirmation: 'newpassword' }

          post '/api/v1/sessions/forgot_password', email: user.email

          user.update_attribute(:password_reminder_expiration, DateTime.now - 1.hour)

          post '/api/v1/sessions/set_new_password', params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json['errors']).to eq({'base'=>['invalid or expired reminder token']})
        end
      end
    end

    describe 'CONFIRM EMAIL' do
      it 'should confirm email' do
        user = create(:user)

        post '/api/v1/sessions/confirm_email', confirm_token: user.confirm_token

        user.reload
        expect(user.email_confirmed).to be_truthy
        expect(response).to match_response_schema('user_public')
      end

      it 'should not confirm email when token invalid' do
        post '/api/v1/sessions/confirm_email', confirm_token: '1234567890'

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({'base'=>['invalid confirmation token']})
      end
    end
  end
end
