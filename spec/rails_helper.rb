# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'simplecov'
SimpleCov.start do
  add_filter 'app/admin/'
end
ENV['RAILS_ENV'] ||= 'test'
ENV['MAILGUN_DOMAIN'] ||= 'isp.dev'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'sidekiq/testing'
Sidekiq::Testing.fake! # fake is the default mode
# Add additional requires below this line. Rails is not loaded until this point!

require 'fakeredis/rspec'
require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.ignore_hosts 'codeclimate.com'
end
WebMock.allow_net_connect!
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before(:each) do
    ActionMailer::Base.deliveries.clear
    Sidekiq::Worker.clear_all
  end
  config.before(:all) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    create(:config, name: 'invoice_line_1', value: '')
    create(:config, name: 'invoice_line_2', value: '')
    create(:config, name: 'invoice_line_3', value: '')
    create(:config, name: 'invoice_line_4', value: '')
    create(:config, name: 'invoice_line_5', value: '')
    create(:config, name: 'invoice_line_6', value: '')
    create(:config, name: 'themes', value: '3D, Abstract, Animal, Galaxy, Digital, Comic')
    create(:email_template, name: 'MalformedPaymentNotifier',
                         description: 'Sent automatically to all admins when malformed payment detected.',
                         subject: 'Malformed payment',
                         content: '<h3>Hi,</h3>You have <b></b>received malformed payment confirmation request.<br><br>Payment ID: <a target="_blank" title="Link: PAYMENT_ID" href="PAYMENT_URL">PAYMENT_ID</a><br><br><p>Regards,<br>Cloud Team</p>')
    create(:email_template, name: 'WaitingProductsNotifier',
                         description: 'Sent automatically/manually to the designer when customer orders product without design.',
                         subject: 'New products are waiting for design',
                         content: '<h3> Hi, </h3><p>New products are waiting for your design<br><br></p><p>PRODUCTS_LIST</p><p>Regards,</p><p>Cloud Team</p>')
    create(:email_template, name: 'AccountResetPassword',
                         description: 'Sent automatically to the customer when they ask to reset their password.',
                         subject: 'Set new password',
                         content: '<h3> Hi, </h3><p>Here is your reset password link:<br><br><a target="_blank" href="REMINDER_URL">REMINDER_URL</a><br><br></p><p>Regards,<br>Cloud Team</p>')
    create(:email_template, name: 'AccountEmailConfirmation',
                         description: 'Sent automatically to the customer when they complete their account registration.	',
                         subject: 'Confirm Your Email',
                         content: '<h3> Hi, </h3><p>Please, confirm your email<br><br><a target="_blank" title="Link: CONFIRMATION_URL" href="CONFIRMATION_URL">CONFIRMATION_URL</a><br><br></p><p>Regards,<br>Cloud Team</p>')
    create(:email_template, name: 'OrderConfirmationMailer',
                         description: 'Sent automatically to the customer when order payment is received.',
                         subject: 'Thank you for your order',
                         content: '' )
  end
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

def auth_header_for(user)
  {"Auth-Token" => user.auth_token}
end
