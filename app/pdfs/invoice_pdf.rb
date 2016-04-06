require 'open-uri'

class InvoicePdf < Prawn::Document
  def initialize(order, view)
    super(top_margin: 70)
    @order = order
    @view = view
    order_number
    shipping_address
    line_items
    total_price
  end

  def order_number
    text "Order \##{@order.id}/#{@order.purchased_at.strftime('%d/%m/%Y')}", size: 25, style: :bold
    move_down 15
    text "Order Status: #{@order.order_status}", size: 12
    text "Order Placed: #{@order.purchased_at.strftime('%B %d, %Y - %I:%M %p')}", size: 12
    move_down 50
  end

  def shipping_address
    text "Shipping Address", size: 13, style: :bold
    move_down 15
    text "#{@order.full_name}", size: 12
    text "#{@order.address}", size: 12
    text "#{@order.city}, #{@order.region}, #{@order.zip}", size: 12
    text "#{@order.country}", size: 12
  end

  def line_items
    move_down 50
    table line_item_rows do
      row(0).font_style = :bold
      columns(1..4).align = :right
      rows(1).width = 108
      self.row_colors = ["DDDDDD", "FFFFFF"]
      self.header = true
    end
  end

  def line_item_rows
    [[ "Image", "Product", "Quantity", "Price", "Subtotal"]] +
        @order.order_items.map do |item|
          [ { image: item.product.image, image_width: 50, image_height: 50 },
            item.product.name,
            item.quantity,
            price(item.price),
            price(item.price*item.quantity) ]
        end
  end

  def price(num)
    @view.number_to_currency(num)
  end

  def total_price
    move_down 30
    text "ORDER SUBTOTAL: #{price(@order.subtotal_cost)}", size: 13, style: :bold, align: :right
    text "SHIPPING: #{price(@order.shipping_cost)}", size: 13, style: :bold, align: :right
    text "TAX(#{price(@order.tax)}%): #{@order.tax_cost}", size: 13, style: :bold, align: :right
    text "Total: #{price(@order.total_cost)}", size: 13, style: :bold, align: :right
  end
end