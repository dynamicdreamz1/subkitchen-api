class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product_template
  has_many :order_items
  validate :cannot_publish
  after_create :set_price
  attachment :image, content_type: ['image/jpeg', 'image/png', 'image/jpg']
  has_many :likes, as: :likeable

  attachment :design
  after_update :check_items_if_ready
  has_many :orders, through: :order_items
  default_scope { where(is_deleted: false) }
  scope :published, -> (user) { where('published = ? AND user_id = ?', true, user.id )}
  scope :published_weekly, -> (user) { where('published = ? AND user_id = ? AND published_at < ?', true, user.id, 1.week.ago )}

  def cannot_publish
    if published && (!author || !author.artist)
      errors.add(:published, "can't be true when you're not an artist")
    end
  end

  def check_items_if_ready
    if design_id_changed? && design_id && design_id_was.nil?
      orders = self.orders.where(order_status: 'processing').distinct
      orders.each do |order|
        if CheckOrderIfReady.new(order).call
          SendOrder.new(order).call
        end
      end
    end
  end

  def set_price
    update_attribute(:price, product_template.price) if product_template
  end
end
