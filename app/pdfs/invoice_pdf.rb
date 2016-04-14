require 'open-uri'

class InvoicePdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  def initialize(invoice)
    super(top_margin: 70)
    @order = invoice.order
    @invoice = invoice
    define_grid(columns: 5, rows: 8, gutter: 10)
    company_address
    logo
    order_number
    shipping_address
    line_items
    total_price
    number_pages '<page>/<total>', start_count_at: 0, page_filter: :all, at: [bounds.right - 50, 0], align: :center, size: 8
  end

  def logo
    image open(Rails.root + 'app/assets/images/logo_1024x1024.jpg'), width: 100, height: 100, at: [425, 725]
  end

  def order_number
    grid([0, 0], [1, 3]).bounding_box do
      text "Order \##{@order.id}/#{@invoice.created_at.strftime('%d/%m/%Y')}", size: 25, style: :bold
      move_down 15
      text "Order Placed: #{@invoice.created_at.strftime('%B %d, %Y - %I:%M %p %Z')}", size: 12
    end
  end

  def shipping_address
    grid([1, 0], [2, 2]).bounding_box do
      move_down 10
      text 'Shipping Address', size: 13, style: :bold
      move_down 10
      text @order.full_name.to_s, size: 12
      text @order.address.to_s, size: 12
      text "#{@order.city}, #{@order.region}", size: 12
      text @order.zip.to_s, size: 12
      text @order.country.to_s, size: 12
      text @order.email.to_s, size: 12
    end
  end

  def company_address
    grid([1, 3], [2, 4]).bounding_box do
      move_down 10
      text @invoice.line_1.to_s, size: 13, style: :bold, align: :left
      move_down 10
      text @invoice.line_2.to_s, size: 12, align: :left
      text @invoice.line_3.to_s, size: 12, align: :left
      text @invoice.line_4.to_s, size: 12, align: :left
    end
  end

  def line_items
    table line_item_rows do
      row(0).font_style = :bold
      column(1).align = :left
      column(1).width = 270
      column(0).width = 60
      column(2).width = 60
      columns(3..4).width = 75
      columns(2..4).align = :right
      self.row_colors = %w(DDDDDD FFFFFF)
      self.header = true
    end
  end

  def line_item_rows
    [%w(Image Product Quantity Price Subtotal)] +
      @order.order_items.map do |item|
        [{ image: item.product.image, image_width: 50, image_height: 50 },
         item.product.name,
         item.quantity,
         price(item.price),
         price(item.price * item.quantity)]
      end
  end

  def price(num)
    number_to_currency(num)
  end

  def total_price
    move_down 40
    text "<b>ORDER SUBTOTAL:</b>#{Prawn::Text::NBSP * 15}#{price(@order.subtotal_cost)}", size: 13, align: :right, inline_format: true
    text "<b>SHIPPING:</b>#{Prawn::Text::NBSP * 19}#{price(@order.shipping_cost)}", size: 13, align: :right, inline_format: true
    text "<b>TAX(#{@order.tax}%):</b>#{Prawn::Text::NBSP * 17}#{price(@order.tax_cost)}", size: 13, align: :right, inline_format: true
    move_down 10
    text "Total:#{Prawn::Text::NBSP * 5}#{price(@order.total_cost)}", size: 20, style: :bold, align: :right, inline_format: true
  end
end
