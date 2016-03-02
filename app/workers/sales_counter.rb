class SalesCounter
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find_by(id: order_id)
    order.order_items.each do |item|
      user = item.product.author
      $redis.incrby("user_#{user.id}_sales_counter", item.quantity)
      count = $redis.get("user_#{user.id}_sales_counter").to_i
      $redis.set("user_#{user.id}_sales_weekly", (user.sales_count_weekly * 100 / count))
    end
  end
end
