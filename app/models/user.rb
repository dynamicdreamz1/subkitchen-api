class User < ActiveRecord::Base
  has_many :products, foreign_key: 'author_id'
  has_many :orders
  has_one :payment, as: :payable
  has_one :company
  has_many :likes
  has_many :order_items, through: :products

  validates :email, presence: true, email: true, uniqueness: true, if: :validate_email?
  validates :handle, uniqueness: { allow_nil: true, allow_blank: true }, presence: { if: :artist }
  validates :name, presence: true, uniqueness: true

  attr_accessor :validate_email

  after_create ChangeStatusIfArtist.new
  after_update ChangeStatusIfArtist.new, if: :artist_changed?

  include SecureToken
  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  uses_secure_token :confirm_token
  has_secure_password

  attachment :profile_image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :shop_banner, content_type: %w(image/jpeg image/png image/jpg)

  scope :with_reminder_token, lambda { |token|
    where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token)
  }

  scope :with_confirm_token, lambda { |token|
    where(confirm_token: token)
  }

  scope :artists, lambda {
    where(artist: true)
  }

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

  def validate_email?
    @validate_email.nil? ? true : @validate_email
  end
end
