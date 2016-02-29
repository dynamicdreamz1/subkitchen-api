class ConfirmUserVerification
  def call
    update_artist
  end

  private

  attr_accessor :payment, :params

  def initialize(payment, params)
    @payment = payment
    @params = params
  end

  def update_artist
    payment.update_attributes(status: params.payment_status, transaction_id: params.transaction_id)
    artist = payment.payable
    artist.update_arrtibute(:status, 'verified')
    payment
  end
end

