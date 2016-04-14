module Artists
  class Api < Grape::API
    resources :artists do
      desc 'return all artists'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
      end
      get do
        artists = User.artists.page(params.page).per(params.per_page)
        ArtistListSerializer.new(artists).as_json
      end

      desc 'return artist by id'
      get ':id' do
        artist = User.find_by!(id: params[:id])
        ArtistSerializer.new(artist).as_json
      end
    end
  end
end
