class User < ActiveRecord::Base
  has_many :products, foreign_key: 'author_id'
  has_many :orders
  has_one :payment, as: :payable
  has_one :company
  has_many :likes
  has_many :user_likes, as: :likeable, class_name: 'Like'
  has_many :order_items, through: :products
  has_many :product_wishes, dependent: :destroy
  has_many :wished_products, through: :product_wishes

  enum status: { unverified: 0, verified: 1, pending: 2 }

  accepts_nested_attributes_for :company

  attr_accessor :oauth_registration

	validates_with FeaturedValidator
  validates :email, presence: true, email: true, uniqueness: true, unless: :oauth_registration?
  validates :handle, uniqueness: { allow_nil: true, allow_blank: true }, presence: { if: :artist }
	validates :name, presence: true, uniqueness: true
  validates :shop_banner, user_images: { width: 1372, height: 315 }
  validate do |record|
    record.errors.add(:password, :blank) unless record.password_digest.present? || oauth_registration?
  end
  validates_length_of :password, maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
  validates_confirmation_of :password, allow_blank: true
  has_secure_password validations: false

  after_create ChangeStatusIfArtist.new
  after_update ChangeStatusIfArtist.new, if: :artist_changed?

  include SecureToken
  include ArtistStatsGetters

  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  uses_secure_token :confirm_token

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  scope :with_reminder_token, -> (token) { where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token) }
  scope :with_confirm_token, -> (token) { where(confirm_token: token) }
  scope :artists, -> { where(artist: true, status: 1) }
	scope :not_artists, -> { where(artist: false) }
	scope :featured_artists, -> { where(artist: true, status: 1, featured: true) }
	scope :featured, -> (featured) { where(artist: true, status: 1, featured: featured) }
  scope :followers, -> (user) { where(id: user.user_likes.pluck(:user_id)) }
  scope :followings, -> (user) {
    where(id: user.likes.where(likeable_type: 'User').pluck(:likeable_id))
  }

  def as_json(params = {})
    UserPublicSerializer.new(self, true).as_json(params)
  end

  private

  def oauth_registration?
    @oauth_registration.nil? ? false : @oauth_registration
	end

	scope :sort_by, lambda { |sort_option|
		direction = (sort_option =~ /asc$/) ? 'ASC' : 'DESC'
		case sort_option.to_s
			when /^created_at_/
				User.artists.order("created_at #{direction}")
			when /^likes_count_/
				User.artists.order("likes_count #{direction}")
			else
				raise(ArgumentError, sort_option.to_s)
		end
	}

	filterrific(
		default_filter_params: { sort_by: 'created_at_desc' },
		available_filters: [ :sort_by, :featured ]
	)
end
