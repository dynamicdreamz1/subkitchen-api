def ConfirmPayment
  def update_order
    payment.update_attributes(status: params.payment_status, transaction_id: params.transaction_id)
    payment.payable.update_arrtibutes(purchased_at: DateTime.now, state: 'inactive')
  end

  def update_artist
    payment.update_attributes(status: params.payment_status, transaction_id: params.transaction_id)
    artist = payment.payable
    artist.update_arrtibutes(status: 'verified')
  end

  private

  attr_accessor :payment, :params

  def initialize(payment, params)
    @payment = payment
    @params = params
  end
end