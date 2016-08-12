require 'concerns/sales_and_earnings_methods'

class SalesAndEarningsCounter
  include Sidekiq::Worker
	include SalesAndEarningsMethods

  def perform(order_id)
    get_order(order_id).order_items.each do |item|
      user = get_user(item)
      set_earnings(item, user) if (earnings_increment_value(item) + get_sales_counter(user)) >= 0
      next unless (item.quantity + get_sales_counter(user)) >= 0
      set_sales(item, user)
    end
  end

  private

	def set_earnings(item, user)
		increment_earnings_counter(user, item)
		earnings = calculate_earnings_percentage(user)
		set_earnings_weekly(user, earnings)
	end

	def set_sales(item, user)
		increment_sales_counter(user, item)
		sales = calculate_sales_percentage(user)
		set_sales_weekly(user, sales)
	end

	def increment_earnings_counter(user, item)
    $redis.incrbyfloat("user_#{user.id}_earnings_counter", earnings_increment_value(item))
  end

  def earnings_increment_value(item)
    item.quantity * profit(item)
  end

  def increment_sales_counter(user, item)
    $redis.incrby("user_#{user.id}_sales_counter", sales_increment_value(item))
  end

  def sales_increment_value(item)
    item.quantity
  end
end
