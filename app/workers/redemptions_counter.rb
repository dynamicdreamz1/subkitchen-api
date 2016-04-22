class RedemptionsCounter
  include Sidekiq::Worker

  def perform(coupon_id)
    increment(coupon_id)
  end

  private

  def increment(id)
    $redis.incr("coupon_#{id}_redemptions_counter")
  end
end
