class ProductTemplate < ActiveRecord::Base
  has_many :products
  belongs_to :shipping
  serialize :size
  attachment :size_chart

  default_scope { where(is_deleted: false) }

  def delete_product_template
    update_attribute(:is_deleted, true)
  end
end
