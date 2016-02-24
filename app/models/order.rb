class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  belongs_to :shipping
  has_one :payment, as: :payable


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
end
