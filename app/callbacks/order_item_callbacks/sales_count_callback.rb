class SalesCountCallback
  def after_save(order_item)
    update_counter_cache(order_item)
  end

  private

  def update_counter_cache(order_item)
    product = order_item.product
    product.sales_count = OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
                                   .where('orders.purchased = ?', true).count
    product.save
  end
end
