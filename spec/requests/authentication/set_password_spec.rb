describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    let(:user) { create(:user, password: 'password') }

    describe '/set_password' do
      context 'with valid params' do
        before(:each) do
          @valid_params = { token: user.password_reminder_token,
                            password: 'newpassword',
                            password_confirmation: 'newpassword' }
          post '/api/v1/sessions/forgot_password', email: user.email
          post '/api/v1/sessions/set_new_password', @valid_params
          user.reload
        end

        it 'should set new password' do
          expect(user.authenticate(@valid_params[:password])).to be_truthy
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should match json response schema' do
          expect(response).to match_response_schema('user_public')
        end
      end

      context 'with invalid password confirmation' do
        before(:each) do
          @invalid_params = { token: user.password_reminder_token,
                              password: 'newpassword',
                              password_confirmation: '' }
          post '/api/v1/sessions/forgot_password', email: user.email
          post '/api/v1/sessions/set_new_password', @invalid_params
          user.reload
        end

        it 'should not set new password' do
          expect(user.authenticate(@invalid_params[:password])).to be_falsey
        end

        it 'should return status unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return error' do
          expect(json['errors']).to eq('base' => ['password and password confirmation does not match'])
        end
      end

      context 'with expired token' do
        before(:each) do
          @invalid_params = { token: user.password_reminder_token,
                              password: 'newpassword',
                              password_confirmation: 'newpassword' }
          post '/api/v1/sessions/forgot_password', email: user.email
          user.update_attribute(:password_reminder_expiration, DateTime.now - 1.hour)
          post '/api/v1/sessions/set_new_password', @invalid_params
          user.reload
        end

        it 'should not set new password' do
          expect(user.authenticate(@invalid_params[:password])).to be_falsey
        end

        it 'should return status unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return error' do
          expect(json['errors']).to eq('base' => ['invalid or expired reminder token'])
        end
      end
    end
  end
end
