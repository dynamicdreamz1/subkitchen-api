class SetProfitCallback
  def after_save(product_template)
		profit = product_template.price * 0.2
    product_template.update_column(:profit, profit)
  end
end
