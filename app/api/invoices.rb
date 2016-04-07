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
        pdf = InvoicePdf.new(order)
        header['Content-Disposition'] = "attachment; filename=order_#{order.id}_#{order.purchased_at.strftime('%d_%m_%Y')}"
        pdf.render
      end
    end
  end
end
