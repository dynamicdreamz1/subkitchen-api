module Artists
  class Api < Grape::API
    resources :artists do
      desc "Return all artists"
      get "" do
        page = params[:page].is_a?(Integer)? params[:page] : 1
        per_page = params[:per_page].is_a?(Integer)? params[:per_page] : 10
        User.artists.page(page).per(per_page)
      end
    end
  end
end