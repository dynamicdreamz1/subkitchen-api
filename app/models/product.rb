class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'
  belongs_to :product_template, touch: true
  has_many :order_items
  validate :cannot_publish
  after_create :set_price
  attachment :image, content_type: ['image/jpeg', 'image/png', 'image/jpg']
  has_many :likes, as: :likeable

  attachment :design
  after_update :check_items_if_ready, if: :design_id_changed? and :design_id != nil and :design_id_was == nil
  has_many :orders, through: :order_items
  default_scope { where(is_deleted: false)}
  scope :published, -> (user) { where('published = ? AND user_id = ?', true, user.id ) }
  scope :published_weekly, -> (user) { where('published = ? AND user_id = ? AND published_at < ?', true, user.id, 1.week.ago )}
  scope :with_product_type, -> (type) { joins(:product_template).where(product_templates: {product_type: type}) }
  scope :with_price_range, -> (range) { where('price > ? AND price < ?', range[0], range[1]) }
  scope :with_tags, -> (tags) { tagged_with(tags, any: true) }
  acts_as_taggable

  def cannot_publish
    if published && (!author || !author.artist)
      errors.add(:published, "can't be true when you're not an artist")
    end
  end

  def check_items_if_ready
    orders = self.orders.where(order_status: 'processing').distinct
    orders.each do |order|
      if CheckOrderIfReady.new(order).call
        SendOrder.new(order).call
      end
    end
  end

  def set_price
    update_column(:price, product_template.price) if product_template
  end

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /asc$/) ? 'ASC' : 'DESC'
    case sort_option.to_s
      when /^created_at_/
        Product.order("created_at #{ direction }")
      when /^name/
        Product.order("name #{ direction }")
      when /^price_/
        Product.order("price #{ direction }")
      when /^best_sellers/
        Product.order("order_items_count #{ direction }")
      else
        raise(ArgumentError, 'Invalid sort option')
    end
   }

  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :with_price_range,
          :with_product_type,
          :with_tags
      ]
  )
end
