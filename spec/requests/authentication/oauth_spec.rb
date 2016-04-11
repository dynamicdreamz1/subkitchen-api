describe Oauth::Api, type: :request do

  describe '/api/v1/oauth' do
    describe 'facebook' do

      context 'invalid' do
        it 'should not be able create user with invalid token' do
          VCR.use_cassette('oauth/facebook/invalid') do
            expect do
              post '/api/v1/oauth/facebook', access_token: 'asd'
            end.to change(User, :count).by(0)
          end
        end

        it 'should return status unprocessable_entity' do
          VCR.use_cassette('oauth/facebook/invalid') do
            post '/api/v1/oauth/facebook', access_token: 'asd'

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'valid' do
        it 'should create new user' do
          VCR.use_cassette('oauth/facebook/valid') do
            expect do
              post '/api/v1/oauth/facebook', access_token: 'test'
            end.to change(User, :count).by(1)
          end
        end

        it 'should return serialized user' do
          VCR.use_cassette('oauth/facebook/valid') do

            post '/api/v1/oauth/facebook', access_token: 'test'

            user = User.last
            expect(response.body).to eq(user.to_json)
          end
        end

        it 'should return status success' do
          VCR.use_cassette('oauth/facebook/valid') do

            post '/api/v1/oauth/facebook', access_token: 'test'

            expect(response).to have_http_status(:success)
          end
        end
      end

      context 'valid with email' do

        before(:each) do
          @user = create(:user, email: 'some@stuff.pl')
        end

        it 'should not create new user' do
          VCR.use_cassette('oauth/facebook/valid_with_email') do

            expect do
              post '/api/v1/oauth/facebook', access_token: 'test'
            end.to change(User, :count).by(0)
          end
        end

        it 'should be able to sign in with facebok to existing account' do
          VCR.use_cassette('oauth/facebook/valid_with_email') do

            post '/api/v1/oauth/facebook', access_token: 'test'

            @user.reload
            expect(response.body).to eq(@user.to_json)
            expect(@user.provider).to eq('facebook')
            expect(@user.uid).to eq('4')
          end
        end

        it 'should return status success' do
          VCR.use_cassette('oauth/facebook/valid_with_email') do

            post '/api/v1/oauth/facebook', access_token: 'test'

            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end