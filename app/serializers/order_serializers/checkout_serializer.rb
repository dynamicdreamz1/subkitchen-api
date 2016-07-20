class CheckoutSerializer
  include ApplicationHelper

  def as_json(options = {})
		add_invoice_data if order.invoice
    add_shipping_address if order.address
    add_errors if order.errors.any?
    add_deleted_items if deleted_items

    data.as_json(options)
  end

  private

  attr_accessor :order, :data
  attr_reader :deleted_items

  def initialize(order, deleted_items = nil)
    @order = order
    @data = { order: order_hash }
    @deleted_items = deleted_items
  end

  def add_invoice_data
    data[:order][:pdf] = order.invoice.pdf_url
	end

  def add_shipping_address
    data[:order][:shipping_address] = shipping_address
  end

  def add_errors
    data[:errors] = order.errors
  end

  def add_deleted_items
    data[:deleted_items] = deleted_items_hash
  end

  def order_hash
    { id: order.id,
      uuid: order.uuid,
			purchased_at: purchased_at,
			purchased: order.purchased,
      status: order.order_status,
      subtotal: order.subtotal_cost,
      shipping_cost: order.shipping_cost,
      tax: order.tax,
      tax_cost: order.tax_cost,
      total_cost: order.total_cost,
      discount: order.discount,
      items: items_hash,
			invoice_id: order.record_number
		}
  end

  def items
    order.order_items.reject { |item| item.product.is_deleted }
	end

	def purchased_at
		order.purchased_at ? order.purchased_at.strftime('%B %d, %Y - %I:%M %p %Z').to_s : nil
	end

  def items_hash
    items.map do |item|
      item_hash(item)
    end
  end

  def item_hash(item)
    { price: item.price,
      subtotal: item.price * item.quantity,
      name: item.product.name,
      id: item.id,
      is_deleted: item.product.is_deleted,
      quantity: item.quantity,
      size: item.size,
      preview_url: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, format: :png),
      product_id: item.product_id }
  end

  def deleted_items_hash
    deleted_items.map do |item|
      { price: item.price,
        name: item.product.name,
        id: item.id,
        quantity: item.quantity,
        size: item.size,
        preview_url: Figaro.env.app_host + Refile.attachment_url(item.product, :preview, format: :png) }
    end
  end

  def shipping_address
    { email: order.email,
      first_name: full_name.first,
      last_name: full_name[1...-1],
      address: order.address,
      city: order.city,
      zip: order.zip,
      region: order.region,
      country: order.country,
      phone: order.try(:phone) }
  end

  def full_name
    order.full_name.split(' ')
  end
end
