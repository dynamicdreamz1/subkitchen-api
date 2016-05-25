class Coupon < ActiveRecord::Base
  has_many :orders

  validates :code, uniqueness: true, unless: :code?
  validates :description, presence: true
  validates :discount, presence: true
  validates :valid_from, presence: true
  validates :valid_until, presence: true
  validates :redemption_limit, presence: true
  validates :discount, inclusion: { in: 0...100, message: '0 - 100 for percentage' }, if: :percentage
  validates_with CouponDateValidator

  after_create :generate_code

  def generate_code
    self.code = SecureRandom.hex(3) if code?
    save
  end

  def code?
    code == ''
  end

  def redemptions_count
    $redis.get("coupon_#{id}_redemptions_counter").to_i
  end
end
