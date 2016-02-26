class BusinessAddressSerializer
  def as_json(options={})
    data =  { company:
                  { name: user.company.name,
                    address: user.company.address,
                    city: user.company.city,
                    zip: user.company.zip,
                    region: user.company.region,
                    country: user.company.country }}

    data[:errors] = user.errors if user.errors.any?

    data.as_json(options)
  end

  private

  attr_reader :user

  def initialize(user)
    @user = user
  end
end