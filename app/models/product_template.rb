class ProductTemplate < ActiveRecord::Base
  has_many :products
  belongs_to :shipping
  serialize :size
  attachment :size_chart

  default_scope { where(is_deleted: false) }
end
