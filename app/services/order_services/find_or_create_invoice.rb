class FindOrCreateInvoice
  def call
    find_or_create
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def find_or_create
    order.invoice || Invoice.create!(order: order,
                                     line_1: Config.invoice_line_1,
                                     line_2: Config.invoice_line_2,
                                     line_3: Config.invoice_line_3,
                                     line_4: Config.invoice_line_4,
                                     line_5: Config.invoice_line_5,
                                     line_6: Config.invoice_line_6)
  end
end
