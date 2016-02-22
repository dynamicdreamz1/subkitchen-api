class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  validates :order_type, uniqueness: { scope: [:user_id, :state] } if :active
  belongs_to :shipping

  def active
    state == :active
  end

  def order_items_exist?
    order_items.each do |item|
      if item.product
        true
      else
        return false
      end
    end
  end

  def update_order
    items = []
    order_items.each do |item|
      item.product ? true : items << item
    end
    OrderItem.destroy(items.map{ |i| i.id })
    items
  end

  def paypal_payment_url(return_path, notify_path)
    values = {
        business: 'klara.hirao-facilitator@elpassion.pl',
        cmd: '_card ',
        upload: 1,
        return: "http://localhost:3000/#{return_path}",
        invoice: id,
        item_name: 'Verification cost',
        notify_url: "http://localhost:3000/#{notify_path}"
    }
    order_items.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => item.price,
        "item_name_#{index+1}" => item.product.name,
        "item_number_#{index+1}" => item.id,
        "quantity_#{index+1}" => item.quantity
      })
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
    end
  end
end
