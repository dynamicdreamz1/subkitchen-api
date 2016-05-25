class SalesAndEarningsCounter
  include Sidekiq::Worker

  def perform(order_id)
    get_order(order_id).order_items.each do |item|
      user = get_user(item)
      set_earnings(item, user) if (earnings_increment_value(item) + get_sales_counter(user)) >= 0
      next unless (item.quantity + get_sales_counter(user)) >= 0
      set_sales(item, user)
    end
  end

  private

  def get_order(order_id)
    Order.find_by(id: order_id)
  end

  def get_user(item)
    item.product.author
  end

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
    item.quantity * item.profit
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
    count = get_earnings_count(user)
    return 0 if count == 0
    (earnings_count_weekly(user) * 100) / count
  end

  def calculate_sales_percentage(user)
    count = get_sales_counter(user)
    return 0 if count == 0
    (sales_count_weekly(user) * 100) / count
  end

  def sales_count_weekly(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
             .where('orders.purchased_at > ?', 1.week.ago)
             .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
             .where('products.author_id = ?', user.id)
             .sum('order_items.quantity')
  end

  def earnings_count_weekly(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
             .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
             .where('products.author_id = ?', user.id)
             .where('orders.purchased_at > ?', 1.week.ago)
             .sum('order_items.quantity*order_items.profit')
  end
end
