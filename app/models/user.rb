class User < ActiveRecord::Base
  attr_accessor :validate_email
  after_create :artist_verify

  include SecureToken
  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token
  uses_secure_token :confirm_token
  has_secure_password

  has_many :products
  has_many :user_verify_notifications
  has_many :orders
  has_one :payment, as: :payable
  has_one :company

  validates :email, presence: true, email: true, uniqueness: true, if: :validate_email?
  validates :handle, uniqueness: true
  validates :name, presence: true, uniqueness: true

  scope :with_reminder_token, lambda { |token|
    where('password_reminder_expiration >= ?', Time.zone.now).where(password_reminder_token: token).first
  }

  scope :with_confirm_token, lambda { |token|
    where(confirm_token: token).first
  }

  scope :artists, lambda {
    where(artist: true)
  }


  def artist_verify
    self.status = :pending if artist
  end

  def as_json(params = {})
    UserPublicSerializer.new(self).as_json(params).merge(auth_token: auth_token)
  end

  private

  def validate_email?
    @validate_email.nil? ? true : @validate_email
  end
end
