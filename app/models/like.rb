class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true
  belongs_to :user

  validates :likeable_type, uniqueness: { scope: [:likeable_id, :user_id]}
  validates_with LikeValidator

  scope :this_week, -> (product_id) { where(likeable_id: product_id).count }
end