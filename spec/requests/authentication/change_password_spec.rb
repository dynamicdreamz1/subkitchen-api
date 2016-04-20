describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    let(:user) { create(:user, password: 'password') }

    describe '/change_password' do
      context 'with valid data' do
        before(:each) do
          @valid_params = { current_password: 'password',
                            password: 'newpassword',
                            password_confirmation: 'newpassword' }
          post '/api/v1/sessions/change_password', @valid_params, auth_header_for(user)
          user.reload
        end

        it 'should change password' do
          expect(user.authenticate(@valid_params[:password])).to be_truthy
          expect(response).to have_http_status(:success)
          expect(response).to match_response_schema('user_public')
        end
      end

      context 'with invalid data' do
        context 'invalid current password' do
          before(:each) do
            @invalid_params = { current_password: 'invalidpassword',
                                password: 'newpassword',
                                password_confirmation: 'newpassword' }
            post '/api/v1/sessions/change_password', @invalid_params, auth_header_for(user)
            user.reload
          end

          it 'should not change password' do
            expect(user.authenticate(@invalid_params[:password])).to be_falsey
            expect(json['errors']).to eq('base' => ['invalid password'])
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context 'invalid password confirmation' do
          before(:each) do
            @invalid_params = { current_password: 'password',
                                password: 'newpassword',
                                password_confirmation: '' }
            post '/api/v1/sessions/change_password', @invalid_params, auth_header_for(user)
            user.reload
          end

          it 'should not change password' do
            expect(user.authenticate(@invalid_params[:password])).to be_falsey
            expect(json['errors']).to eq('base' => ['password and password confirmation does not match'])
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
