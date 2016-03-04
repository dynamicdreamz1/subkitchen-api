class SalesAndEarningsCounter
  include Sidekiq::Worker

  def perform(order_id)
    order = get_order(order_id)
    order.order_items.each do |item|
      user = get_user(item)

      if (earnings_increment_value(item) + get_sales_counter(user)) >= 0
        increment_earnings_counter(user, item)
        earnings = calculate_earnings_percentage(user)
        set_earnings_weekly(user, earnings)
      end

      if (item.quantity + get_sales_counter(user)) >= 0
        increment_sales_counter(user, item)
        sales = calculate_sales_percentage(user)
        set_sales_weekly(user, sales)
      end
    end
  end

  private

  def get_order(order_id)
    Order.find_by(id: order_id)
  end

  def get_user(item)
    item.product.author
  end

  def get_earnings_count(user)
    $redis.get("user_#{user.id}_earnings_counter").to_i
  end

  def get_sales_counter(user)
    $redis.get("user_#{user.id}_sales_counter").to_i
  end

  def increment_earnings_counter(user, item)
    $redis.incrbyfloat("user_#{user.id}_earnings_counter", earnings_increment_value(item))
  end

  def earnings_increment_value(item)
    item.quantity * item.product.product_template.profit
  end

  def increment_sales_counter(user, item)
    $redis.incrby("user_#{user.id}_sales_counter", sales_increment_value(item))
  end

  def sales_increment_value(item)
    item.quantity
  end

  def set_earnings_weekly(user, earnings_percentage)
    $redis.set("user_#{user.id}_earnings_weekly", earnings_percentage)
  end

  def set_sales_weekly(user, sales_percentage)
    $redis.set("user_#{user.id}_sales_weekly", sales_percentage)
  end

  def calculate_earnings_percentage(user)
    earnings = get_earnings_count(user)
    earnings == 0 ? 0 : (user.earnings_count_weekly * 100 / earnings)
  end

  def calculate_sales_percentage(user)
    sales = get_sales_counter(user)
    sales == 0 ? 0 : (user.sales_count_weekly * 100 / sales)
  end
end
