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
        user
      end
    end
  end
end