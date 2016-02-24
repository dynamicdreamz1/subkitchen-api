class PaypalPayment
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
        cmd: '_cart',
        upload: 1,
        return: Figaro.env.app_host+"#{@return_path}",
        invoice: @payment.id,
        notify_url: Figaro.env.app_host+"/payment_notifications"
    }
    @payment.payable.order_items.each_with_index do |item, index|
      values.merge!({
                        "amount_#{index+1}" => item.price,
                        "item_name_#{index+1}" => item.product.name,
                        "item_number_#{index+1}" => item.id,
                        "quantity_#{index+1}" => item.quantity
                    })
    end
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end
end