class SetTaxAndShipping
  def after_create(order)
    order.update_columns(tax: Config.tax, shipping_cost: Config.shipping_cost)
  end
end