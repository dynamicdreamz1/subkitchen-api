class DenyUserVerification
  def call
    deny_verification
  end

  private

  attr_accessor :payment, :params

  def initialize(payment, params)
    @payment = payment
    @params = params
  end

  def deny_verification
    User.transaction do
      payment.update(payment_status: 'denied')
      artist = payment.payable
      artist.update(status: 'unverified')
      payment
    end
  end
end
