class CreateCompanyAddress
  def call
    create_company_address
  end

  private

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def create_company_address
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