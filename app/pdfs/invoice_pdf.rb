require 'open-uri'

class InvoicePdf < Prawn::Document

  include ActionView::Helpers::NumberHelper

  def initialize(order)
    super(top_margin: 70)
    @order = order
    define_grid(columns: 4, rows: 8, gutter: 10)
    company_address
    image open(Rails.root+'app/assets/images/logo_1024x1024.jpg'), width: 100, height: 100, at: [425,700]
    order_number
    shipping_address
    line_items
    total_price
  end

  def order_number
    grid([0,0],[0,2]).bounding_box do
      text "Order \##{@order.id}/#{@order.purchased_at.strftime('%d/%m/%Y')}", size: 25, style: :bold
      move_down 15
      text "Order Status: #{@order.order_status}", size: 12
      text "Order Placed: #{@order.purchased_at.strftime('%B %d, %Y - %I:%M %p')}", size: 12
      move_down 50
    end
  end

  def shipping_address
    grid([1,0], [2,2]).bounding_box do
      move_down 30
      text "Shipping Address", size: 13, style: :bold
      move_down 10
      text "#{@order.full_name}", size: 12
      text "#{@order.address}", size: 12
      text "#{@order.city}, #{@order.region}", size: 12
      text "#{@order.zip}", size: 12
      text "#{@order.country}", size: 12
      text "#{@order.email}", size: 12
    end
  end

  def company_address
    grid([1, 3],[2,3]).bounding_box do
      move_down 30
      text "#{Config.invoice_line_1}", size: 13, style: :bold, align: :right
      move_down 10
      text "#{Config.invoice_line_2}", size: 12, align: :right
      text "#{Config.invoice_line_3}", size: 12, align: :right
      text "#{Config.invoice_line_4}", size: 12, align: :right
      text "#{Config.invoice_line_5}", size: 12, align: :right
      text "#{Config.invoice_line_6}", size: 12, align: :right
    end
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
    number_to_currency(num)
  end

  def total_price
    move_down 40
    text "ORDER SUBTOTAL: #{price(@order.subtotal_cost)}", size: 13, style: :bold, align: :right
    text "SHIPPING: #{price(@order.shipping_cost)}", size: 13, style: :bold, align: :right
    text "TAX(#{price(@order.tax)}%): #{@order.tax_cost}", size: 13, style: :bold, align: :right
    text "Total: #{price(@order.total_cost)}", size: 13, style: :bold, align: :right
  end
end