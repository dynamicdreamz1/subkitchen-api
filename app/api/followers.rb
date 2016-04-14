module Followers
  class Api < Grape::API
    resources :users do
      desc 'list of followers'
      get ':id/followers' do
        user = User.find(params.id)
        { followers: User.followers(user), followings: User.followings(user) }
      end

      desc 'follow/unfollow artist'
      post ':id/toggle_follow' do
        authenticate!
        artist = User.find(params.id)
        ToggleFollow.new(current_user, artist).call
        { artist_followers: User.followers(artist).count, current_user_followings: User.followings(current_user).count }
      end
    end
  end
end
