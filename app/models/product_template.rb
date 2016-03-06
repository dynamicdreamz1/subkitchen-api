class ProductTemplate < ActiveRecord::Base
  has_many :products
  after_update :update_product_prices, if: :price_changed?
  serialize :size
  attachment :size_chart

  default_scope { where(is_deleted: false) }

  def update_product_prices
    products.each do |product|
      product.update(price: self.price)
    end
  end
end
