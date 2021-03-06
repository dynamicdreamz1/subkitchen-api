class PaypalPaymentRequest
  def call
    url
  end

  private

	attr_reader :order

  def initialize(payment, return_path)
    @payment = payment
    @return_path = return_path
		@order = payment.payable
  end

  def url
    values = {
      business: Figaro.env.paypal_seller,
      cmd: '_cart',
      upload: 1,
      return: "#{Figaro.env.frontend_host}#{@return_path.to_s}",
      invoice: @payment.id,
      notify_url: "#{Figaro.env.app_host}/api/v1/payment_notification"
    }
		values.merge!(discount_amount_cart: order.discount) if order.coupon
    @payment.payable.order_items.each_with_index do |item, index|
      next unless item.quantity > 0
			shipping = (index == 0) ? Config.shipping_cost : 0
      values.merge!("amount_#{index + 1}" => item.price,
                    "item_name_#{index + 1}" => item.product.name,
                    "item_number_#{index + 1}" => item.id,
                    "quantity_#{index + 1}" => item.quantity,
										"shipping_#{index + 1}" => shipping)
		end
    Figaro.env.paypal_url + values.to_query
  end
end
