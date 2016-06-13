module Newsletters
  class Api < Grape::API
    resource :newsletter_receivers do
      desc 'add email to newsletter'
      params do
        requires :newsletter_receiver, type: Hash do
          requires :email, type: String
        end
      end
      post do
        NewsletterReceiver.create!(email: params.newsletter_receiver.email)
      end

      desc 'remove email from newsletter'
      params do
        requires :newsletter_receiver, type: Hash do
          requires :email, type: String
        end
      end
      delete do
        receiver = NewsletterReceiver.find_by!(email: params.newsletter_receiver.email)
        receiver.delete
      end
    end
  end
end
