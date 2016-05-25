class AddressSerializer
  def as_json(options = {})
    data = {
      id: 'current',
      first_name: user.first_name,
      last_name: user.last_name,
      address: user.address,
      city: user.city,
      zip: user.zip,
      region: user.region,
      country: user.country,
      phone: user.phone
    }

    data[:errors] = user.errors if user.errors.any?

    { address: data }.as_json(options)
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end
end
