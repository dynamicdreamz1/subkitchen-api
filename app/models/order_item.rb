class OrderItem < ActiveRecord::Base
  belongs_to :product, counter_cache: true
  belongs_to :order
  belongs_to :template_variant

  after_create SetOrderItem.new

  validates_with OrderItemValidator
  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :template_variant_id, presence: true
  validates :size, presence: true
  validates :quantity, presence: true

  def product
    Product.unscoped.find_by(id: product_id)
  end
end
