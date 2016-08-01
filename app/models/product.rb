class Product < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  has_many :order_items
  has_many :likes, as: :likeable
  has_many :orders, through: :order_items
  has_many :comments
  has_many :product_wishes, foreign_key: 'wished_product_id', dependent: :destroy
  belongs_to :product_template
  has_many :template_variants, through: :product_template

  validates_with PublishedValidator
  validates :image, image: { range: 1024...5000 }
  validates :name, presence: true
  validates :description, presence: true
  validates :product_template_id, presence: true

  after_create SetProduct.new
  after_update SendOrderIfItemsReady.new, if: :design_id_changed?
  after_save SetPublishedAt.new, if: :published_changed?

  attachment :image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :preview, content_type: %w(image/jpeg image/png image/jpg)
  attachment :design, content_type: 'application/pdf'

  acts_as_taggable

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  scope :ready_to_print, -> { where.not(design_id: nil) }
  scope :waiting, -> { joins(:orders).where(design_id: nil).where(orders: { order_status: 2 }) }
	scope :published_all, -> { where(published: true) }
	scope :featured, -> (is_featured) { where(featured: is_featured) }
	scope :featured_products, -> { where(featured: true) }
  scope :published_only, -> (is_published) { where(published: is_published) }
  scope :published, -> (user) { where(published: true, author: user) }
  scope :published_weekly, -> (user) { where(published: true, author: user, published_at: 1.week.ago..DateTime.now) }
  scope :with_product_type, -> (type) { joins(:product_template).where(product_templates: { product_type: type }) }
  scope :with_price_range, -> (range) { where(price: range) }
  scope :with_tags, -> (tags) { tagged_with(tags, any: true) }
  scope :with_author, -> (author_id) { where(author_id: author_id) }
  scope :search_query, -> (query) {
    return nil if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map { |e| (e.gsub('*', '%') + '%').gsub(/%+/, '%') }

    terms.map{|term| "LOWER(name) LIKE (?)"}

    where(
      terms.map { |term|
        "(LOWER(name) LIKE (?))"
      }.join(' OR '),
      *terms
    )

  }
  scope :sort_by, lambda { |sort_option|
                    direction = (sort_option =~ /asc$/) ? 'ASC' : 'DESC'
                    case sort_option.to_s
                    when /^created_at_/
                      Product.order("created_at #{direction}")
                    when /^name/
                      Product.order("lower(name) #{direction}")
                    when /^price_/
                      Product.order("price #{direction}")
                    when /^best_sellers/
                      Product.order("sales_count #{direction}")
                    else
                      raise(ArgumentError, sort_option.to_s)
                    end
                  }

  filterrific(
    default_filter_params: { sort_by: 'created_at_desc' },
    available_filters: [
      :search_query,
      :sort_by,
      :with_price_range,
      :with_product_type,
      :with_tags,
      :with_author,
      :published_only,
			:featured
    ]
  )

  def product_template
    ProductTemplate.unscoped.find_by(id: product_template_id)
  end

  def author
    User.unscoped.find_by(id: author_id)
  end
end
