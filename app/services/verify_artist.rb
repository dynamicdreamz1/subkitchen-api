class VerifyArtist
  def call
    payment = Payment.find_or_create_by(payable: user, payment_status: 'pending')
    return false unless update_user && update_address && !already_paid?
    url = PaypalUserVerification.new(payment, params.return_path).call
    { url: url }
  end

  private

  attr_accessor :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def update_address
    params.has_company ? CompanyAddress.new(user, params).call : true
  end

  def update_user
    user_params = { artist: true, has_company: params.has_company, handle: params.handle}
    user.update(user_params)
  end

  def already_paid?
    Payment.find_by(payable: user, payment_status: 'completed')
  end
end