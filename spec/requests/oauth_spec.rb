describe Oauth::Api, type: :request do
  describe '/api/v1/oauth' do
    describe 'facebook' do
      it 'should not be able to connect with invalid token' do
        VCR.use_cassette('oauth/facebook/invalid') do
          expect do
            post '/api/v1/oauth/facebook', access_token: 'asd'
          end.to change(User, :count).by(0)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it 'should be able to connect' do
        VCR.use_cassette('oauth/facebook/valid') do
          expect do
            post '/api/v1/oauth/facebook', access_token: 'test'
          end.to change(User, :count).by(1)
          expect(response).to have_http_status(:success)
          user = User.last
          expect(response.body).to eq(user.to_json)
        end
      end

      it 'should be able to connect with facebok to existing account' do
        user = create(:user, email: 'some@stuff.pl')
        VCR.use_cassette('oauth/facebook/valid_with_email') do
          expect do
            post '/api/v1/oauth/facebook', access_token: 'test'
          end.to change(User, :count).by(0)
          expect(response).to have_http_status(:success)
          user.reload
          expect(response.body).to eq(user.to_json)
          expect(user.provider).to eq('facebook')
          expect(user.uid).to eq('4')
        end
      end
    end
  end
end
