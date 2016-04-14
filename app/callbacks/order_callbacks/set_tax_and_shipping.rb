class SetTaxAndShipping
  def after_create(order)
    order.update_columns(tax: Config.tax.to_d, shipping_cost: Config.shipping_cost.to_d)
  end
end
