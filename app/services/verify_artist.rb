class VerifyArtist
  def call
    payment = Payment.find_or_create_by(payable: user)
    return false unless update_user && update_address && payment.pending?
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
end
