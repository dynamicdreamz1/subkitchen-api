source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.5'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma'
gem 'grape'
gem 'grape-swagger'
gem 'grape-middleware-logger'
gem 'bcrypt'
gem 'markdown-rails'
gem 'email_validator'
gem 'koala'
gem 'rails-i18n'
gem 'kaminari'
gem 'rack-cors', require: 'rack/cors'
gem 'refile', require: 'refile/rails'
gem 'refile-mini_magick'
gem 'refile-s3'
gem 'figaro'
gem 'iso_country_codes'
gem 'faker'
gem 'sidekiq'
gem 'redis'
gem 'connection_pool'
gem 'filterrific'
gem 'acts-as-taggable-on', '~> 3.4'
gem 'activeadmin', github: 'activeadmin'
gem 'active_admin_editor', github: 'ejholmes/active_admin_editor'
gem 'refile-input', require: ['inputs/refile_input']
gem 'devise'
gem 'stripe'
gem 'stripe-ruby-mock', '~> 2.2.2', require: 'stripe_mock'
gem 'activeadmin-dragonfly', github: 'stefanoverna/activeadmin-dragonfly'
gem 'activeadmin-wysihtml5', github: 'jsetiadarma/activeadmin-wysihtml5'
gem 'http'
gem 'prawn'
gem 'prawn-table'
gem 'jquery-minicolors-rails'
gem 'activeadmin-minicolors', github: 'kholdrex/activeadmin-minicolors'
gem 'activeadmin_addons'

group :production do
  gem 'rails_12factor'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  gem 'rspec-nc'
  gem 'guard-rspec', require: false
  gem 'letter_opener_web', '~> 1.2.0'
end

group :test do
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: false
  gem 'webmock'
  gem 'vcr'
  gem 'json-schema'
  gem 'fakeredis', git: 'git://github.com/guilleiguaran/fakeredis.git', require: 'fakeredis/rspec'
  gem 'timecop'
  gem 'pdf-inspector', require: 'pdf/inspector'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'pry'
  gem 'hirb'
  gem 'awesome_print'
end
