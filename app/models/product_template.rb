class ProductTemplate < ActiveRecord::Base
  has_many :products

  after_update UpdateProductPrices.new, if: :price_changed?

  serialize :size

  attachment :size_chart
  attachment :template_image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :template_mask, content_type: %w(image/png)

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  validates :template_image, image: { width: 1024, height: 1024 }
  validates :template_mask, image: { width: 1024, height: 1024 }

  def sizes_raw
    self.size.join("\n") unless self.size.nil?
  end

  def sizes_raw=(values)
    self.size = values.to_s.split(/[\r\n]+/).reject{|e| e.blank?}
  end
end
