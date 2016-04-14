class WaitingProductsNotifierPreview < ActionMailer::Preview
  def waiting_products
    WaitingProductsNotifier.notify('test@email.com', products: Product.all.limit(3))
  end
end
