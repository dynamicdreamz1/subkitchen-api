class ProductTemplate < ActiveRecord::Base
  has_many :products
  has_many :template_variants
  has_many :products
  has_many :colors, through: :template_variants
  accepts_nested_attributes_for :template_variants

	after_update UpdateProductPrices.new, if: :price_changed?
	after_save SetProfitCallback.new, if: :price_changed?

  serialize :size

  attachment :size_chart
  attachment :template_image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :template_mask, content_type: %w(image/png)

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }

  validates :template_image, image: { width: 1024, height: 1024 }, presence: true
  validates :template_mask, image: { width: 1024, height: 1024 }, presence: true
  validates :price, presence: true
  validates :size, presence: true
  validates :product_type, presence: true
	validates :description, presence: true
  validate  :all_sizes_are_valid

  def sizes_raw
    size.join("\n") unless size.nil?
  end

  def sizes_raw=(values)
    self.size = values.to_s.split(/[\r\n]+/).reject(&:blank?)
  end

  def t6_size
    size_new = []
    self.size.each do |pt_size|
      size_new << get_value(pt_size)
    end
    return size_new
  end

  def get_value(pt_size)
    if T6_SIZES[pt_size].nil?
      return pt_size
    else
      T6_SIZES[pt_size]
    end
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

  SIZE_LIST =['NA','XXS','XS','S','M','L','XL','XXL','XXXL','28W','30W','32W','34W','36W','38W','40W','4','5/6','7/8','10','12','6M','12M','2Y','3Y']

  private
  def all_sizes_are_valid
    unless self.size.nil?
     self.size.each do |size_name|
      if !SIZE_LIST.include?(size_name)
        errors.add(:size, "#{size_name} is not valid")
      end
     end
    end
  end
end
