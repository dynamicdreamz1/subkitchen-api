class NotifyDesigners
  def call
    notify_designers
  end

  private

  attr_reader :waiting_products

  def initialize(order)
    @waiting_products = Order.waiting_products(order)
  end

  def notify_designers
    WaitingProductsNotifier.notify(designers.strip.split(';'), waiting_products.to_a).deliver_later if waiting_products.present? && designers.present?
  end

  def designers
    Config.designers
  end
end