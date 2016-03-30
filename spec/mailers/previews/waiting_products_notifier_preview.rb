class WaitingProductsNotifierPreview < ActionMailer::Preview
  def waiting_products
    WaitingProductsNotifier.notify_single('test@email.com')
  end
end