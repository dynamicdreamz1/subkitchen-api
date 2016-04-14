class SendOrderIfItemsReady
  def after_update(product)
    if product.design_id.present? && product.design_id_was.nil?
      orders = get_orders(product)
      orders.each do |order|
        SendOrder.new(order).call if CheckOrderIfReady.new(order).call
      end
    end
  end

  private

  def get_orders(product)
    product.orders.where(order_status: 2).distinct
  end
end
