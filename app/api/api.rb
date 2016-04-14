class Api < Grape::API
  use Grape::Middleware::Logger

  version 'v1', using: :path
  format :json

  rescue_from ActiveRecord::RecordNotFound do
    error!({ errors: { base: ['record not found'] } }, 404)
  end

  rescue_from ActiveRecord::RecordNotUnique do
    error!('', 422)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    error!({ errors: { base: [e.message] } }, 422)
  end

  helpers do
    def authenticate!
      error!({ errors: { base: ['401 Unauthorized'] } }, 401) unless current_user
    end

    def current_user
      @current_user ||= User.where(auth_token: headers['Auth-Token']).first
    end
  end

  mount AppConfig::Api
  mount Accounts::Api
  mount Addresses::Api
  mount AccountsArtist::Api
  mount Sessions::Api
  mount Products::Api
  mount Orders::Api
  mount Artists::Api
  mount Users::Api
  mount PaypalHooks::Api
  mount Oauth::Api
  mount Payments::Api
  mount Likes::Api
  mount Promoters::Api
  mount Comments::Api
  mount AccountsOrders::Api
  mount AccountsDesigns::Api
  mount ProductTemplates::Api
  mount Invoices::Api
  mount Followers::Api
  mount WishList::Api

  add_swagger_documentation(api_version: 'v1', hide_documentation_path: true, base_path: '/api')
end
