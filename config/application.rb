require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SubKitchen
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # config.paths.add File.join('app'), glob: File.join('**', '*.rb')
    config.autoload_paths += %W(#{config.root}/app/api)
    config.autoload_paths += %W(#{config.root}/app/services/order_services)
    config.autoload_paths += %W(#{config.root}/app/services/payment_services)
    config.autoload_paths += %W(#{config.root}/app/services/product_services)
    config.autoload_paths += %W(#{config.root}/app/services/user_services)
    config.autoload_paths += %W(#{config.root}/app/serializers/account_serializers)
    config.autoload_paths += %W(#{config.root}/app/serializers/comment_serializers)
    config.autoload_paths += %W(#{config.root}/app/serializers/order_serializers)
    config.autoload_paths += %W(#{config.root}/app/serializers/product_serializers)
    config.autoload_paths += %W(#{config.root}/app/serializers/product_template_serializers)
    config.autoload_paths += %W(#{config.root}/app/callbacks/order_callbacks)
    config.autoload_paths += %W(#{config.root}/app/callbacks/order_item_callbacks)
    config.autoload_paths += %W(#{config.root}/app/callbacks/product_callbacks)
    config.autoload_paths += %W(#{config.root}/app/callbacks/product_template_callbacks)
    config.autoload_paths += %W(#{config.root}/app/callbacks/user_callbacks)
    config.autoload_paths += %W(#{config.root}/app/presenters)

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
