class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    respond_to do |format|
      format.pdf do
        pdf = InvoicePdf.new(@order, view_context)
        send_data(pdf.render, filename: "invoice_#{@order.purchased_at}.pdf", type: 'application/pdf')
      end
    end
  end
end