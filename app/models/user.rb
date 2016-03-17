class User < ActiveRecord::Base
  has_many :products, foreign_key: 'author_id'
  has_many :orders
  has_one :payment, as: :payable
  has_one :company
  has_many :likes
  has_many :order_items, through: :products

  accepts_nested_attributes_for :company

  attr_accessor :oauth_registration

  validates :email, presence: true, email: true, uniqueness: true, unless: :oauth_registration?, on: :create
  validates :handle, uniqueness: { allow_nil: true, allow_blank: true }, presence: { if: :artist }
  validates :name, presence: true, uniqueness: true
  validates_with ArtistValidator
  validate do |record|
    record.errors.add(:password, :blank) unless record.password_digest.present? || oauth_registration?
  end
  validates_length_of :password, maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
  validates_confirmation_of :password, allow_blank: true
  has_secure_password validations: false


  after_create ChangeStatusIfArtist.new
  after_update ChangeStatusIfArtist.new, if: :artist_changed?

  include SecureToken
  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  uses_secure_token :confirm_token


  attachment :profile_image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :shop_banner, content_type: %w(image/jpeg image/png image/jpg)

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  scope :with_reminder_token, lambda { |token| where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token) }
  scope :with_confirm_token, lambda { |token| where(confirm_token: token) }
  scope :artists, lambda { where(artist: true) }
  scope :not_artists, lambda { where(artist: false) }

  def as_json(params = {})
    UserPublicSerializer.new(self).as_json(params).merge(auth_token: auth_token)
  end

  def sales_count
    $redis.get("user_#{id}_sales_counter").to_i
  end

  def sales_weekly
    $redis.get("user_#{id}_sales_weekly").to_i
  end

  def sales_count_weekly
    count = 0
    order_items.each do |item|
      if item.order.purchased_at > 1.week.ago
        count += item.quantity
      end
    end
    count
    # order_items.pluck(:id)
    # OrderItem.where(user_id: order_items.pluck(:id)).select('SUM(quantity) AS quantity_sum').order('quantity_sum')
  end

  def likes_count
    $redis.get("user_#{id}_likes_counter").to_i
  end

  def likes_weekly
    $redis.get("user_#{id}_likes_weekly").to_i
  end

  def likes_count_weekly
    count = 0
    products.each do |product|
      count += Like.this_week(product.id)
    end
    count
    # Like.week(products.pluck(:id), 'Product').count
  end

  def published_count
    $redis.get("user_#{id}_published_counter").to_i
  end

  def published_weekly
    $redis.get("user_#{id}_published_weekly").to_i
  end

  def published_count_weekly
    products.select{ |product| product.published_at > 1.week.ago }.count
  end

  def earnings_count
    $redis.get("user_#{id}_earnings_counter").to_i
  end

  def earnings_weekly
    $redis.get("user_#{id}_earnings_weekly").to_i
  end

  def earnings_count_weekly
    count = 0
    order_items.each do |item|
      if item.order.purchased_at > 1.week.ago
        count += item.quantity * item.product.product_template.profit
      end
    end
    count
  end

  private

  def oauth_registration?
    @oauth_registration.nil? ? false : @oauth_registration
  end
end
