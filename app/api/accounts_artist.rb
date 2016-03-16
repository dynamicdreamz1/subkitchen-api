module AccountsArtist
  class Api < Grape::API

    resource :account do
      resource :artist do

        desc 'artist stats'
        get 'stats' do
          authenticate!
          if current_user.artist
            StatsSerializer.new(current_user).as_json
          else
            error!({errors: {base: ['you are not authorized']}}, 422)
          end
        end
      end
    end
  end
end
