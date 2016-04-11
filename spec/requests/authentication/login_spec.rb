describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    describe '/login' do
      let(:user){ create(:user) }

      context 'with valid data' do

        before(:each) do
          @params = { email: user.email, password: 'password' }
          post '/api/v1/sessions/login', @params
          user.reload
        end

        it 'should authenticate' do
          expect(user.authenticate(@params[:password])).to be_truthy
        end

        it 'should return logged in user' do
          expect(json['user']['name']).to eq(user.name)
          expect(json['user']['auth_token']).to eq(user.auth_token)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should match json response schema' do
          expect(response).to match_response_schema('user_public')
        end
      end

      context 'with invalid data' do

        before(:each) do
          @invalid_params = { email: 'test@test.test', password: 'password' }
          post '/api/v1/sessions/login', @invalid_params
          user.reload
        end

        it 'should return status unprocessable_entity' do
          expect(response).to have_http_status(:not_found)
        end

        it 'should return error' do
          expect(json['errors']).to eq({'base'=>['record not found']})
        end
      end
    end
  end
end
