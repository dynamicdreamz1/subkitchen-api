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
    User.transaction do
      payment.update(payment_token: params.txn_id, payment_status: 'completed')
      artist = payment.payable
      artist.update(status: 'verified')
      payment
    end
  end
end

