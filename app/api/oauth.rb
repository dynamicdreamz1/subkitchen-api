module Oauth
  class Api < Grape::API
    resource :oauth do
      desc 'facebook connect'
      params do
        requires :access_token
      end
      post 'facebook' do
        user = OauthRegister.new(:facebook, params.access_token).call
        error!('', :unprocessable_entity) unless user && user.persisted?
        status(200)
        return UserPublicSerializer.new(user, true).as_json
      end
    end
  end
end
