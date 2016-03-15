class ProductTemplate < ActiveRecord::Base
  has_many :products

  after_update UpdateProductPrices.new, if: :price_changed?

  serialize :size

  attachment :size_chart
  attachment :template_image

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
end