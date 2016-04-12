describe AccountsArtist::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true) }

  describe '/account/artist/stats' do

    context 'artist' do
      before(:each) do
        get '/api/v1/account/artist/stats', {}, auth_header_for(artist)
      end

      it 'should get statistics for artist' do
        expect(response).to match_response_schema('stats')
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'not artist' do
      before(:each) do
        get '/api/v1/account/artist/stats', {}, auth_header_for(user)
      end

      it 'should not get statistics for user' do
        expect(json['errors']).to eq({'base'=>['you are not authorized']})
      end

      it 'should return status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end