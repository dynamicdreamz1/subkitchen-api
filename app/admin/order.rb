ActiveAdmin.register Order do
  config.sort_order = 'id_asc'
  actions :index, :show

  filter :purchased_at

  scope :all
  scope :creating
  scope :payment_pending
  scope :processing
	scope :cooking
	# scope :completed
	scope :failed

  member_action :invoice, method: :get do
    redirect_to Figaro.env.app_host + "/api/v1/invoices?uuid=#{resource.uuid}"
  end

  index do
		column('Number') do |order|
			order.record_number
		end
    column('Date', &:created_at)
    column(:order_status)
		column(:total_cost)
		column(:user)
    actions defaults: false do |order|
      link_to('View', admin_order_path(order), method: :get) + ' ' +
        if order.invoice
          link_to('Invoice', invoice_admin_order_path(order), method: :get)
        end
    end
  end

  show do |order|
    tabs do
      tab('Overview') do
        attributes_table do
          row('Date') { order.created_at }
          row(:uuid)
          row(:user)
          row(:order_status)
          row(:shipping_cost)
          row(:tax)
          row(:tax_cost)
          row(:subtotal_cost)
          row(:total_cost)
          row(:purchased_at)
        end
      end

      tab 'Shipping address' do
        attributes_table do
          row(:full_name)
          row(:email)
          row(:address)
          row(:region)
          row(:zip)
          row(:city)
          row(:country)
        end
      end

      tab 'Items' do
        table_for order.order_items do
          column(:price)
          column(:quantity)
          column(:size)
          column('Product Name') { |item| item.product.name }
          column('Product Author') { |item| item.product.author.name }
          column('') { |item| link_to 'View', admin_product_path(item.product) }
        end
      end

      if order.payment
        tab 'Payment' do
          attributes_table do
            row('Type') { order.payment.payment_type }
            row('Token') { order.payment.payment_token }
            row('Status') { order.payment.payment_status }
            row('Created At') { order.payment.created_at }
          end
        end
      end
    end
  end
end
