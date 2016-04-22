class NewsletterReceiver < ActiveRecord::Base
  validates :email, uniqueness: true, presence: true
end
