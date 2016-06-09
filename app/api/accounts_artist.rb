module AccountsArtist
  class Api < Grape::API
    resource :artist_stats do
      desc 'artist stats'
      get do
        authenticate!
        if current_user.artist
          StatsSerializer.new(current_user).as_json
        else
          error!({ errors: { base: ['you are not authorized'] } }, 401)
        end
      end
    end
  end
end
