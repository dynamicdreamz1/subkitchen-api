class UpdateUserAddress
  def call
    update_address
  end

  private

  attr_accessor :user
  attr_reader :params

  def update_address
    user.update_attributes(
      first_name: params.first_name,
      last_name: params.last_name,
      address: params.address,
      city: params.city,
      zip: params[:zip],
      region: params.region,
      country: params.country,
      phone: (params.phone ? params.phone : '')
    )
    user
  end

  def initialize(user, params)
    @params = params
    @user = user
  end
end
