class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  validates :likeable_type, uniqueness: { scope: [:likeable_id, :user_id]}
end


