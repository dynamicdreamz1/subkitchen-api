class SalesCountCallback
  def after_save(order)
    update_counter_cache(order)
  end

  private

  def update_counter_cache(order)
    order.products.each do |product|
      product.sales_count = OrderItem.where('order_items.product_id = ?', product.id)
                              .joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
                              .where('orders.purchased = ?', true).sum('order_items.quantity')
      product.save
    end
  end
end
