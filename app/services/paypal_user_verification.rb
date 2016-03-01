class PaypalUserVerification
  def call
    url
  end

  private

  def initialize(payment, return_path)
    @payment = payment
    @return_path = return_path
  end

  def url
    values = {
        business: Figaro.env.paypal_seller,
        cmd: '_xclick',
        upload: 1,
        return: Figaro.env.frontend_host+"#{@return_path}",
        invoice: @payment.id,
        notify_url: Figaro.env.app_host+"/user_verify_notification",
        item_name: 'user verifiaction',
        amount: 1
    }
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end
end
