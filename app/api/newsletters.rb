module Newsletters
  class Api < Grape::API

    resource :newsletter_receivers do

      desc 'add email to newsletter'
      params do
        requires :email, type: String
      end
      post do
        NewsletterReceiver.create!(email: params.email)
      end

      desc 'remove email from newsletter'
      params do
        requires :email, type: String
      end
      delete do
        receiver = NewsletterReceiver.find_by!(email: params.email)
        receiver.delete
      end
    end
  end
end
