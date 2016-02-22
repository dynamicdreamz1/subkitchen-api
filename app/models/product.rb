class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product_template
  has_many :order_items
  after_create :set_price

  default_scope { where(is_deleted: false) }

  def set_price
    self.price = product_template.price
  end
end
