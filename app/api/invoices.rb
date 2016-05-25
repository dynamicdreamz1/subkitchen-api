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
        order = Order.find_by!(uuid: params.uuid)
        invoice = Invoice.find_by!(order_id: order.id)
        header['Content-Disposition'] =
          "attachment; filename=order_#{order.id}_#{invoice.created_at.strftime('%d_%m_%Y')}"
        InvoicePdf.new(invoice).render
      end
    end
  end
end
