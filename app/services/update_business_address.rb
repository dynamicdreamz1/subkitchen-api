class UpdateBusinessAddress
  def call
    update_business_address
  end

  private

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def update_business_address
    company = Company.create(
               company_name: @params.company_name,
               address: @params.address,
               city: @params.city,
               zip: @params.zip,
               region: @params.region,
               country: @params.country,
               user: @artist
    )
    company
  end
end