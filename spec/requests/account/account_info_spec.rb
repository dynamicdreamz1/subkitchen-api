describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true, handle: 'artist') }

  describe '/api/v1/account' do

    describe 'UPDATE user' do

      context 'artist false' do
        it 'should update user info' do
          params = { name: 'test' }

          put "/api/v1/account/name", params, auth_header_for(user)

          user.reload
          expect(user.name).to eq('test')
          expect(response.body).to eq(user.to_json)
        end
      end

      context 'artist true' do
        it 'should update user handle' do
          params =  { handle: 'testtest' }

          put "/api/v1/account/handle", params, auth_header_for(artist)

          artist.reload
          expect(artist.handle).to eq('testtest')
        end
      end

      it 'should send confirmation email after email update' do
        params = { email: 'test@gmail.com' }

        expect do
          put "/api/v1/account/email", params, auth_header_for(user)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
