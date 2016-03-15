class Like < ActiveRecord::Base
  belongs_to :likeable, polymorphic: true, counter_cache: true
  belongs_to :user

  validates :likeable_type, uniqueness: { scope: [:likeable_id, :user_id], if: :user_id}
  validates :likeable_type, uniqueness: { scope: [:likeable_id, :uuid]}
  validates_with LikeValidator

  scope :this_week, -> (product_id) { where(likeable_id: product_id).count }
  # scope :this_week, -> (ids, type) {
  #   this_week = [Date.today.end_of_day..(Date.today-7.days).beginning_of_day]
  #   where(likeable_id: ids, likeable_type: type, crated_at: this_week)
  # }
end
