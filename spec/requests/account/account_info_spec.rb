describe Accounts::Api, type: :request do
  let(:artist) { create(:user, artist: true, handle: 'artist') }

  describe '/api/v1/account' do
    describe 'update user' do
      context 'with email' do
        before(:each) do
          params = { user: { name: 'test', handle: 'testtest', email: 'testartist@gmail.com' } }
          put "/api/v1/users/#{artist.id}", params, auth_header_for(artist)
          artist.reload
        end

        it 'should return status success' do
          expect(response).to have_http_status(:success)
        end

        it 'should send email confirmation' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should change name' do
          expect(artist.name).to eq('test')
        end

        it 'should change handle' do
          expect(artist.handle).to eq('testtest')
        end

        it 'should return user' do
          expect(response.body).to eq(artist.to_json)
        end
      end

      context 'without email' do
        before(:each) do
          params = { user: { name: 'test', handle: 'testtest' } }
          put "/api/v1/users/#{artist.id}", params, auth_header_for(artist)
          artist.reload
        end

        it 'should not send email confirmation' do
          expect(ActionMailer::Base.deliveries.count).to eq(0)
        end
      end
    end
  end
end
