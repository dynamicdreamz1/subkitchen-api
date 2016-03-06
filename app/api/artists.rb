module Artists
  class Api < Grape::API
    resources :artists do
      desc 'return all artists'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
      end
      get do
        User.artists.page(params.page).per(params.per_page)
      end

      desc 'return artist by id'
      get ':id' do
        artist = User.find_by(id: params[:id])
        unless artist
          status :unprocessable_entity
        end
        artist
      end
    end
  end
end