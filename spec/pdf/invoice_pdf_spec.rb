require 'rails_helper'

RSpec.describe InvoicePdf do

  include ActionView::Helpers::NumberHelper

  before(:each) do
    @order = create(:order,
      purchased: true,
      purchased_at: DateTime.now,
      full_name: 'John Doe',
      address: '90 Allen Rd',
      zip: 'E3 5JZ',
      city: 'London',
      country: 'UK',
      region: 'London')
    @invoice = create(:invoice, order: @order,
      line_1: 'line1',
      line_2: 'line2',
      line_3: 'line3',
      line_4: 'line4',
      line_5: 'line5',
      line_6: 'line6')
    @item = create(:order_item, order: @order, product: create(:product), quantity: 2, price: 2)
    pdf = InvoicePdf.new(@invoice)
    @text_analysis = PDF::Inspector::Text.analyze(pdf.render)
  end

  it 'should has header' do
    expect(@text_analysis.strings).to include("Order \##{@order.id}/#{@order.purchased_at.strftime('%d/%m/%Y')}")
  end

  it 'should has order status' do
    expect(@text_analysis.strings).to include("Order Status: #{@order.order_status}")
  end

  it 'should has date' do
    expect(@text_analysis.strings).to include("Order Placed: #{@order.purchased_at.strftime('%B %d, %Y - %I:%M %p')}")
  end

  it 'should has shipping address' do
    expect(@text_analysis.strings).to include("#{@order.full_name}")
    expect(@text_analysis.strings).to include("#{@order.address}")
    expect(@text_analysis.strings).to include("#{@order.city}, #{@order.region}")
    expect(@text_analysis.strings).to include("#{@order.zip}")
    expect(@text_analysis.strings).to include("#{@order.country}")
    expect(@text_analysis.strings).to include("#{@order.email}")
  end

  it 'should has company info' do
    expect(@text_analysis.strings).to include("#{@invoice.line_1}")
    expect(@text_analysis.strings).to include("#{@invoice.line_2}")
    expect(@text_analysis.strings).to include("#{@invoice.line_3}")
    expect(@text_analysis.strings).to include("#{@invoice.line_4}")
    expect(@text_analysis.strings).to include("#{@invoice.line_5}")
    expect(@text_analysis.strings).to include("#{@invoice.line_6}")
  end

  it 'should has prices' do
    expect(@text_analysis.strings).to include("ORDER SUBTOTAL: #{number_to_currency(@order.subtotal_cost)}")
    expect(@text_analysis.strings).to include("SHIPPING: #{number_to_currency(@order.shipping_cost)}")
    expect(@text_analysis.strings).to include("TAX(#{number_to_currency(@order.tax)}%): #{@order.tax_cost}")
    expect(@text_analysis.strings).to include("Total: #{number_to_currency(@order.total_cost)}")
  end

  it 'should has items' do
    expect(@text_analysis.strings).to include("#{@item.product.name}")
    expect(@text_analysis.strings).to include("#{@item.quantity}")
    expect(@text_analysis.strings).to include("#{number_to_currency(@item.price)}")
    expect(@text_analysis.strings).to include("#{number_to_currency(@item.quantity*@item.price)}")
  end
end