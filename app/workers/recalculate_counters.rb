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

  def earnings(user)
    count = 0
    user.order_items.each do |item|
      count += item.quantity * item.product.product_template.profit
    end
    count
  end

  def sales(user)
    count = 0
    user.order_items.each do |item|
      count += item.quantity
    end
    count
  end

  def likes(user)
    count = 0
    user.products.each do |product|
      count += product.likes_count
    end
    count
  end

  def published(user)
    user.products.select{ |product| product.published }.count
  end
end