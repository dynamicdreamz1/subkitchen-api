module Invoices
  class Api < Grape::API
    content_type :pdf, 'application/pdf'
    format :pdf

    resources :invoices do
      desc 'get pdf invoice'
      params do
        requires :uuid, type: String
      end
      get do
        Invoice.destroy_all
        order = Order.find_by!(uuid: params.uuid)
        invoice = FindOrCreateInvoice.new(order).call
        pdf = InvoicePdf.new(invoice)
        header['Content-Disposition'] = "attachment; filename=order_#{order.id}_#{invoice.created_at.strftime('%d_%m_%Y')}"
        pdf.render
      end
    end
  end
end
