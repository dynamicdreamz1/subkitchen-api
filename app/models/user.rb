class User < ActiveRecord::Base
  has_many :products, foreign_key: 'author_id'
  has_many :orders
  has_one :payment, as: :payable
  has_one :company
  has_many :likes
  has_many :order_items, through: :products

  accepts_nested_attributes_for :company

  attr_accessor :oauth_registration

  validates :email, presence: true, email: true, uniqueness: true, unless: :oauth_registration?
  validates :handle, uniqueness: { allow_nil: true, allow_blank: true }, presence: { if: :artist }
  validates :name, presence: true, uniqueness: true
  validates :shop_banner, image: { width: 1920, height: 750 }
  validate do |record|
    record.errors.add(:password, :blank) unless record.password_digest.present? || oauth_registration?
  end
  validates_length_of :password, maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
  validates_confirmation_of :password, allow_blank: true
  has_secure_password validations: false


  after_create ChangeStatusIfArtist.new
  after_update ChangeStatusIfArtist.new, if: :artist_changed?

  include SecureToken
  include RedisCounterGetters

  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  uses_secure_token :confirm_token


  attachment :profile_image, content_type: %w(image/jpeg image/png image/jpg)
  attachment :shop_banner, content_type: %w(image/jpeg image/png image/jpg)

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscoped.where(is_deleted: true) }
  scope :with_reminder_token, -> (token) { where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token) }
  scope :with_confirm_token, -> (token) { where(confirm_token: token) }
  scope :artists, -> { where(artist: true) }
  scope :not_artists, -> { where(artist: false) }

  def as_json(params = {})
    UserPublicSerializer.new(self, true).as_json(params)
  end

  private

  def oauth_registration?
    @oauth_registration.nil? ? false : @oauth_registration
  end
end
