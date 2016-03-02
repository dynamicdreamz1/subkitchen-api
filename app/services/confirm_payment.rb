class ConfirmPayment
  def call
    update_order
  end

  private

  attr_accessor :payment, :params

  def initialize(payment, params)
    @payment = payment
    @params = params
  end

  def update_order
    payment.update(status: params.payment_status)
    order = payment.payable
    order.update(purchased_at: DateTime.now, state: 'inactive')
    SalesCounter.perform_async(order.id)
    payment
  end
end