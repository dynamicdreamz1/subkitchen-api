describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    it 'should be able to authenticate' do
      user = create(:user)

      post '/api/v1/sessions/login', email: user.email, password: 'password'

      expect(response).to have_http_status(:success)
      expect(json['name']).to eq(user.name)
      expect(json['auth_token']).to eq(user.auth_token)
    end

    it 'should be able to register' do
      params =  { email: 'test@gmail.com', name: 'test', password: 'password', password_confirmation: 'password', artist: 'false' }
      expect do
        post '/api/v1/sessions/register', params
      end.to change(User, :count).by(1)
      expect(response).to have_http_status(:success)
    end

    it 'should be able to change password' do
      user = create(:user, password: 'password')
      new_params = { current_password: 'password', password: 'newpassword', password_confirmation: 'newpassword' }

      post '/api/v1/sessions/change_password', new_params, auth_header_for(user)

      expect(response).to have_http_status(:success)
      user.reload
      expect(user.authenticate('newpassword')).to be_truthy
    end

    it 'should receive email with link' do
      user = create(:user)

      expect do
        post '/api/v1/sessions/forgot_password', email: user.email
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'should be able to set new password' do
      user = create(:user)
      params = { token: user.password_reminder_token, password: 'newpassword', password_confirmation: 'newpassword' }

      post '/api/v1/sessions/forgot_password', email: user.email
      post '/api/v1/sessions/set_new_password', params

      expect(response).to have_http_status(:success)
      user.reload
      expect(user.authenticate('newpassword')).to be_truthy
    end

    it 'should receive email with confirmation link after registration' do
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

    it 'should confirm email' do
      user = create(:user)
      post '/api/v1/sessions/confirm_email', confirm_token: user.confirm_token
      user.reload
      expect(user.email_confirmed).to be_truthy
    end
  end
end
