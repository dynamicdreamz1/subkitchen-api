class SetTaxAndShipping
  def after_create(record)
    record.update(tax: Config.tax, shipping_cost: Config.shipping_cost)
  end
end