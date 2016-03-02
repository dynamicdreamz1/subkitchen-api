class SalesCounter
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    order.order_items.each do |item|
      user_id = item.product.user_id
      $redis.incrby("user_#{user_id}_sales_counter", item.quantity)
    end
  end
end
