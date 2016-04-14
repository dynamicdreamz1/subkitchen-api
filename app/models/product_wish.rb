class ProductWish < ActiveRecord::Base
  belongs_to :user
  belongs_to :wished_product, class_name: 'Product'

  validates :user_id, uniqueness: { scope: [:user_id, :wished_product_id] }
end
