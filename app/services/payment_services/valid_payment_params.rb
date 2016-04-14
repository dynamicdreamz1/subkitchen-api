class ValidPaymentParams
  def call
    check_if_valid
  end

  private

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def check_if_valid
    (params.payment_type == 'stripe' && params.stripe_token) || \
      (params.payment_type == 'paypal' && params.return_path)
  end
end
