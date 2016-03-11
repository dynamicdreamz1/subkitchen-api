ActiveAdmin.register Order do
  actions :index, :show

  index do
    column('Date') { |order| order.created_at.strftime('%d-%m-%Y') }
    column(:order_status)
    column(:total_cost)
    actions
  end

  show do |order|
    tabs do
      tab('Overview') do
        attributes_table do
          row('Date') { order.created_at.strftime('%d-%m-%Y') }
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
          column(:product_name)
          column(:product_author)
          column(''){ |item| link_to 'View', admin_product_path(item.product)}
        end
      end

      tab 'Payment' do
        table_for order.payment do
          column(:payment_type)
          column(:payment_token)
          column(:payment_status)
          column(:created_at)
        end
      end
    end
  end
end
