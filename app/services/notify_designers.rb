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
    DesignerNotifier.notify_designers(waiting_products) if waiting_products.present? && designers.present?
  end

  def designers
    Config.designers
  end
end