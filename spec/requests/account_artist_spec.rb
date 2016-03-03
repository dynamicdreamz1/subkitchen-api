describe AccountsArtist::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true) }

  describe '/account/artist/stats' do
    it 'should get statistics for artist' do
      get '/api/v1/account/artist/stats', {}, auth_header_for(artist)

      expect(response).to have_http_status(:success)
      expect(response).to match_response_schema('stats')
    end

    it 'should not get statistics for user' do
      get '/api/v1/account/artist/stats', {}, auth_header_for(user)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors']).to eq({'base'=>['you are not authorized']})
    end
  end
end
