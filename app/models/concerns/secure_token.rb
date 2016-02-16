# remove after upgrade to rails 5
# https://github.com/rails/rails/blob/master/activerecord/lib/active_record/secure_token.rb

require 'securerandom'

module SecureRandom
  BASE58_ALPHABET = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a - %w(0 O I l)
  # SecureRandom.base58 generates a random base58 string.
  #
  # The argument _n_ specifies the length, of the random string to be generated.
  #
  # If _n_ is not specified or is nil, 16 is assumed. It may be larger in the future.
  #
  # The result may contain alphanumeric characters except 0, O, I and l
  #
  #   p SecureRandom.base58 #=> "4kUgL2pdQMSCQtjE"
  #   p SecureRandom.base58(24) #=> "77TMHrHJFvFDwodq8w7Ev2m7"
  #
  def self.base58(n = 16)
    SecureRandom.random_bytes(n).unpack('C*').map do |byte|
      idx = byte % 64
      idx = SecureRandom.random_number(58) if idx >= 58
      BASE58_ALPHABET[idx]
    end.join
  end
end

module SecureToken
  extend ActiveSupport::Concern

  class_methods do
    # Example using has_secure_token
    #
    #   # Schema: User(token:string, auth_token:string)
    #   class User < ActiveRecord::Base
    #     uses_secure_token
    #     uses_secure_token :auth_token
    #   end
    #
    #   user = User.new
    #   user.save
    #   user.token # => "4kUgL2pdQMSCQtjE"
    #   user.auth_token # => "77TMHrHJFvFDwodq8w7Ev2m7"
    #   user.regenerate_token # => true
    #   user.regenerate_auth_token # => true
    #
    # SecureRandom::base58 is used to generate the 24-character unique token, so collisions are highly unlikely.
    #
    # Note that it's still possible to generate a race condition in the database in the same way that
    # <tt>validates_uniqueness_of</tt> can. You're encouraged to add a unique index in the database to deal
    # with this even more unlikely scenario.
    def uses_secure_token(attribute = :token, length = 128)
      # Load securerandom only when has_secure_token is used.
      define_method("regenerate_#{attribute}") do
        update! attribute => self.class.generate_unique_secure_token(attribute, length)
      end
      before_create do
        send("#{attribute}?") ||
          send("#{attribute}=", self.class.generate_unique_secure_token(attribute, length))
      end
    end

    def generate_unique_secure_token(attribute, length = 120)
      token = SecureRandom.base58(length)
      return(generate_unique_secure_token(attribute, length)) unless uniq_token(token, attribute)
      token
    end

    def uniq_token(token, attribute)
      !where(attribute => token).exists?
    end
  end
end
