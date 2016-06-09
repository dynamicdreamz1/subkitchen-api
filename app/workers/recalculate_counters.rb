class RecalculateCounters
  include Sidekiq::Worker

  def perform
    User.all.each do |user|
      $redis.set("user_#{user.id}_earnings_counter", earnings(user))
      $redis.set("user_#{user.id}_sales_counter", sales(user))
      $redis.set("user_#{user.id}_published_counter", published(user))
      $redis.set("user_#{user.id}_likes_counter", likes(user))
      $redis.set("user_#{user.id}_earnings_weekly", percentage(user, 'earnings'))
      $redis.set("user_#{user.id}_sales_weekly", percentage(user, 'sales'))
      $redis.set("user_#{user.id}_published_weekly", percentage(user, 'published'))
      $redis.set("user_#{user.id}_likes_weekly", percentage(user, 'likes'))
    end
  end

  private

  def sales(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
             .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
             .where('products.author_id = ?', user.id)
             .where('orders.purchased = ?', true)
             .sum('order_items.quantity')
  end

  def earnings(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
             .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
             .where('products.author_id = ?', user.id)
             .where('orders.purchased = ?', true)
             .sum('order_items.quantity*order_items.profit')
  end

  def likes(user)
    Like.where(likeable_id: user.products.pluck(:id), likeable_type: 'Product').count
  end

  def published(user)
    user.products.select(&:published).count
  end

  def sales_weekly(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
      .where('orders.purchased_at > ?', 1.week.ago)
      .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
      .where('products.author_id = ?', user.id)
      .sum('order_items.quantity')
  end

  def earnings_weekly(user)
    OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
      .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
      .where('products.author_id = ?', user.id)
      .where('orders.purchased_at > ?', 1.week.ago)
      .sum('order_items.quantity*order_items.profit')
  end

  def likes_weekly(user)
    Like.where(likeable_id: user.products.pluck(:id), likeable_type: 'Product')
      .where('created_at >= ?', 1.week.ago).count
  end

  def published_weekly(user)
    user.products.select do |product|
      product.published && product.published_at > 1.week.ago
    end.count
  end

  def percentage(user, name)
    count =  $redis.get("user_#{user.id}_#{name}_counter").to_i
    return 0 if count == 0
    (method("#{name}_weekly").call(user) * 100) / count
  end
end
