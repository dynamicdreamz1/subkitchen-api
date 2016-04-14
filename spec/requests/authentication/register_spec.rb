describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    describe 'REGISTER by form' do
      context 'with valid params' do
        before(:each) do
          @valid_params = { email: 'test@gmail.com',
                            name: 'test',
                            password: 'password',
                            password_confirmation: 'password',
                            artist: 'false' }
          post '/api/v1/sessions/register', @valid_params
        end

        it 'should be able to register' do
          expect(User.count).to eq(1)
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should match response schema' do
          expect(response).to match_response_schema('user_public')
        end

        it 'should receive email with confirmation link' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context 'with invalid params' do
        before(:each) do
          params = { email: 'test@gmail.com',
                     name: 'test',
                     password: '',
                     password_confirmation: '',
                     artist: 'false' }
          post '/api/v1/sessions/register', params
        end

        it 'should not be able to register' do
          expect(User.count).to eq(0)
        end

        it 'should return error' do
          expect(json['errors']).to eq('password' => "can't be blank")
        end

        it 'should return status unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
