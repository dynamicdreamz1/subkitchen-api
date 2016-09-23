class OrderItem < ActiveRecord::Base
  belongs_to :product, counter_cache: true
  has_many :product_variants, through: :product
  belongs_to :order, touch: true
  belongs_to :template_variant

  after_create SetOrderItem.new

  validates_with OrderItemValidator
  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :template_variant_id, presence: true
  validates :size, presence: true
  validates :quantity, presence: true

  scope :last_sales, -> (author_id) { joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
                                        .joins('RIGHT  JOIN products ON products.id = order_items.product_id')
                                        .where('products.author_id = ?', author_id)
                                        .where('orders.purchased = ?', true)
                                        .order('orders.purchased_at DESC') }

  def product
    Product.unscoped.find_by(id: product_id)
  end

  def product_variant
    product.product_variants.where(size: size).first
  end

  def t6_size
    size_new = []
    self.size.each do |pt_size|
      size_new << T6_SIZES[pt_size] || pt_size
    end
    return size_new
  end

  T6_SIZES = {
    '3S' => 'XXXS',
    '2S' => 'XXS',
    'XS' => 'XS',
    'SM' => 'S',
    'MD' => 'M',
    'LG' => 'L',
    'XL' => 'XL',
    '2X' => 'XXL',
    '3X' => 'XXXL'
  }

end
