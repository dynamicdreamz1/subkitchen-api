class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product_template
  has_many :order_items
  after_create :set_price
  attachment :image

  default_scope { where(is_deleted: false) }

  def set_price
    update_attribute(:price, product_template.price) if product_template
  end
end
