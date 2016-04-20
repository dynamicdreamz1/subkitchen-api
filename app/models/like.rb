class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user

  validates :likeable_type, uniqueness: { scope: [:likeable_type, :likeable_id, :user_id], if: :user_id }
  validates :likeable_type, uniqueness: { scope: [:likeable_type, :likeable_id, :uuid] }
  validates :likeable_id, presence: true
  validates :likeable_type, presence: true
  validates_with LikeValidator

  scope :this_week, -> (product_id) { where(likeable_id: product_id).count }
end
