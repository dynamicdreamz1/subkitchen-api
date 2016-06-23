module Artists
  class Api < Grape::API
    resources :users do
      desc 'return all artists'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 2
				optional :sorted_by, type: String, default: 'created_at_desc'
				optional :featured, type: Boolean, default: false
      end
      get do
				filterrific = Filterrific::ParamSet.new(User, sort_by: params.sorted_by, featured: params.featured)
        artists = User.filterrific_find(filterrific).page(params.page).per(params.per_page)
        ArtistListSerializer.new(artists).as_json
      end
    end
  end
end
