class Coupon < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true
  validates :discount, presence: true
  validates :valid_from, presence: true
  validates :valid_until, presence: true
  validates :redemption_limit, presence: true
  validates :discount, inclusion: { in: 0...100, message: '0 - 100 for percentage' }, if: :percentage
end
