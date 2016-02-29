class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_one :payment, as: :payable
  after_create :set_tax_and_shipping
  enum status: [:active, :inactive]

  def set_tax_and_shipping
    self.update_attributes(tax: Config.tax, shipping_cost: Config.shipping_cost)
  end
end
