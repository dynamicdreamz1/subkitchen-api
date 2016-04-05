describe Artists::Api, type: :request do
  describe '/api/v1/artists' do
    it 'should return first page of artists' do
      create(:user, artist: true, status: 'verified')

      get '/api/v1/artists'

      serialized_artists = ArtistListSerializer.new(User.artists.page(1)).as_json
      expect(response.body).to eq(serialized_artists.to_json)
    end

    it 'should respond status success' do
      create(:user, artist: true, status: 'verified')

      get '/api/v1/artists'

      expect(response).to have_http_status(:success)
    end


    it 'should paginate' do
      create(:user, artist: true, status: 'verified')
      create(:user, artist: true, status: 'verified')

      get '/api/v1/artists', { page: 1, per_page: 1 }

      serialized_artists = ArtistListSerializer.new(User.artists.page(1).per(1)).as_json
      expect(response).to match_response_schema('artists')
      expect(response.body).to eq(serialized_artists.to_json)

      get '/api/v1/artists', { page: 2, per_page: 1 }

      serialized_artists = ArtistListSerializer.new(User.artists.page(2).per(1)).as_json
      expect(response).to match_response_schema('artists')
      expect(response.body).to eq(serialized_artists.to_json)
    end
  end

  describe '/api/v1/artists/:id' do
    it 'should respond status success' do
      artist = create(:user, artist: true)

      get "/api/v1/artists/#{artist.id}"

      expect(response).to have_http_status(:success)
    end

    it 'returns artist' do
      artist = create(:user, artist: true)

      get "/api/v1/artists/#{artist.id}"

      artist.reload
      serialized_artist = ArtistSerializer.new(artist).as_json

      expect(response.body).to eq(serialized_artist.to_json)
    end

    it 'match json schema' do
      artist = create(:user, artist: true)

      get "/api/v1/artists/#{artist.id}"

      expect(response).to match_response_schema('artist')
    end
  end
end
