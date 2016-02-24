class Api < Grape::API
  use Grape::Middleware::Logger

  version 'v1', using: :path
  format :json

  rescue_from ActiveRecord::RecordNotFound do
    error!('', 404)
  end

  rescue_from ActiveRecord::RecordNotUnique do
    error!('', 422)
  end

  helpers do
    def authenticate!
      error!('401 Unauthorized', 401) unless current_user
    end

    def current_user
      @current_user ||= User.where(auth_token: headers['Auth-Token']).first
    end
  end

  mount Sessions::Api
  mount Products::Api
  mount Artists::Api
  mount Orders::Api


  add_swagger_documentation(api_version: 'v1', hide_documentation_path: true, base_path: '/api')
end
