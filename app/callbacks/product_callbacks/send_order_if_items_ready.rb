class SendOrderIfItemsReady
  def after_update(product_variant)
    trigger(product_variant)
  end

  def after_save(product_variant)
    trigger(product_variant)
  end

  private

  def trigger(product_variant)
    if product_variant.design_id.present? && product_variant.design_id_was.nil?
      orders = get_orders(product_variant.product)
      orders.each do |order|
        if CheckOrderIfReady.new(order).call
          order.update(order_status: 'cooking')
          SendOrder.new(order).call
        end
      end
    end
  end

  def get_orders(product)
    product.orders.where(order_status: 2).distinct
  end
end
