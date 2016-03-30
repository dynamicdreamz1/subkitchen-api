class WaitingProductsNotifierPreview < ActionMailer::Preview
  def waiting_products
    WaitingProductsNotifier.notify('test@email.com', Product.all.limit(3))
  end
end