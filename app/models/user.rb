class User < ActiveRecord::Base
  attr_accessor :validate_email

  has_secure_password

  include SecureToken
  uses_secure_token :auth_token
  uses_secure_token :password_reminder_token

  has_many :products

  validates :email, presence: true, email: true, uniqueness: true, if: :validate_email?

  scope :with_reminder_token, lambda { |token|
    where('password_reminder_expiration >= ?', Time.zone.now)
      .where(password_reminder_token: token)
  }

  def as_json(params = {})
    UserPublicSerializer.new(self).as_json(params).merge(auth_token: auth_token)
  end

  private

  def validate_email?
    @validate_email.nil? ? true : @validate_email
  end

  def self.artists
    where(artist: true)
  end
end
