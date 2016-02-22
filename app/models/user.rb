class User < ActiveRecord::Base
  attr_accessor :validate_email
  after_create :artist_verify

  include SecureToken
  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  has_secure_password

  has_many :products
  has_many :user_verify_notifications
  has_many :orders

  validates :email, presence: true, email: true, uniqueness: true, if: :validate_email?

  scope :with_reminder_token, lambda { |token|
    where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token).first
  }

  def artist_verify
    self.status = :pending if artist
  end

  scope :artists, lambda {
    where(artist: true)
  }

  def as_json(params = {})
    UserPublicSerializer.new(self).as_json(params).merge(auth_token: auth_token)
  end

  private

  def validate_email?
    @validate_email.nil? ? true : @validate_email
  end
end
