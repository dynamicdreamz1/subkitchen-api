describe Accounts::Api, type: :request do
  let(:artist){ create(:user, artist: true, handle: 'artist') }

  describe '/api/v1/account' do

    describe 'UPDATE user' do

      it 'should update user' do
        params = { user: { name: 'test', handle: 'testtest', email: 'testartist@gmail.com' } }

        expect do
          put "/api/v1/users/#{artist.id}", params, auth_header_for(artist)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        artist.reload
        expect(artist.name).to eq('test')
        expect(response.body).to eq(artist.to_json)
        expect(artist.handle).to eq('testtest')
      end
    end
  end
end
