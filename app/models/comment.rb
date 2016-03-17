class Comment < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  scope :product, -> (product_id) { where(product_id: product_id) }
end
