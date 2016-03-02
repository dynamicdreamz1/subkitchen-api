class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  validates :likeable_type, uniqueness: { scope: [:likeable_id, :user_id]}
  validate :cannot_like_own

  def cannot_like_own
    if likeable.author.id == user_id
      errors.add(:user_id, 'cannot like own')
    end
  end

  scope :this_week, -> (product_id) { where(likeable_id: product_id).count }
end