class VerifyArtist
  def call
    user.update(artist: true, has_company: params.has_company)
    payment = Payment.find_or_create_by(payable: user)
    return false unless update_address(user, params) && payment.pending?
    url = PaypalUserVerification.new(payment, params.return_path).call
    { url: url }
  end

  private
  attr_accessor :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def update_address(current_user, params)
    params.has_company ? CompanyAddress.new(current_user, params).call : true
  end
end
