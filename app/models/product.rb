class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :product_template
  has_many :order_items
  has_many :likes, as: :likeable
  has_many :orders, through: :order_items
  has_many :comments

  validates_with PublishedValidator
  validates :image, product_image: true

  after_create SetProduct.new
  after_update SendOrderIfItemsReady.new, if: :design_id_changed?
  after_save SetPublishedAt.new, if: :published_changed?

  attachment :image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :design

  acts_as_taggable

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  scope :ready_to_print, -> { where.not(design_id: nil)}
  scope :waiting, -> { joins(:orders).where(design_id: nil).where(orders: { order_status: 'processing' } ) }
  scope :published_all, -> { where(published: true) }
  scope :published, -> (user) { where(published: true, author: user) }
  scope :published_weekly, -> (user) { where(published: true, author: user, published_at: 1.week.ago..DateTime.now) }
  scope :with_product_type, -> (type) { joins(:product_template).where(product_templates: {product_type: type}) }
  scope :with_price_range, -> (range) { where(price: range[0]..range[1]) }
  scope :with_tags, -> (tags) { tagged_with(tags, any: true) }
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

  def product_template
    ProductTemplate.unscoped.find_by(id: product_template_id)
  end

  def author
    User.unscoped.find_by(id: author_id)
  end
end
