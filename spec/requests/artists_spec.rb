describe Artists::Api, type: :request do
  describe '/api/v1/artists' do
    it 'returns first page of artists' do
      create(:user, artist: true)

      get '/api/v1/artists'

      expect(response).to have_http_status(:success)
      expect(response.body).to eq(User.artists.page(1).to_json)
    end
  end

  describe '/api/v1/artists/:id' do
    it 'returns artist' do
      artist = create(:user, artist: true)

      get "/api/v1/artists/#{artist.id}"

      expect(response.body).to eq(artist.to_json)
    end
  end
end
