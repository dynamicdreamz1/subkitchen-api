class RecalculateCounters
  include Sidekiq::Worker

  def perform
    User.all.each do |user|
      $redis.set("user_#{user.id}_earnings_counter", earnings(user))
      $redis.set("user_#{user.id}_sales_counter", sales(user))
      $redis.set("user_#{user.id}_published_counter", published(user))
      $redis.set("user_#{user.id}_likes_counter", likes(user))
    end
  end

  def sales(user)
    OrderItem.joins("RIGHT JOIN orders ON orders.id = order_items.order_id")
        .joins("RIGHT  JOIN products ON products.id = order_items.product_id")
        .where("products.author_id = ?", user.id)
        .sum("order_items.quantity")
  end

  def earnings(user)
    OrderItem.joins("RIGHT JOIN orders ON orders.id = order_items.order_id")
        .joins("RIGHT  JOIN products ON products.id = order_items.product_id")
        .where("products.author_id = ?", user.id)
        .sum("order_items.quantity*order_items.profit")
  end

  def likes(user)
    Like.where(likeable_id: user.products.pluck(:id), likeable_type: 'Product').count
  end

  def published(user)
    user.products.select{ |product| product.published }.count
  end
end