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
    payment.update_attribute(:status, 'Completed')
    artist = payment.payable
    artist.update_attribute(:status, 'verified')
    payment
  end
end

