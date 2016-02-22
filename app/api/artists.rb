module Artists
  class Api < Grape::API
    resources :artists do
      desc 'return all artists'
      get '' do
        page = params[:page].to_i != 0? params[:page] : 1
        per_page = params[:per_page].to_i != 0? params[:per_page] : 30
        User.artists.page(page).per(per_page)
      end

      desc 'return artist by id'
      get ':id' do
        artist = User.find_by(id: params[:id])
        if artist
          artist
        else
          status :unprocessable_entity
        end
      end
    end
  end
end