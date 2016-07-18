class Payout < ActiveRecord::Base
	belongs_to :user

	validates :user_id, presence: true
	validates :value, presence: true

	scope :user, -> (user_id) { where(user_id: user_id) }
end
