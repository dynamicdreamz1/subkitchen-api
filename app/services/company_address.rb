class CompanyAddress

  def create_company
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

  def update_company
    @artist.company.update_attributes(
        company_name: @params.company_name,
        address: @params.address,
        city: @params.city,
        zip: @params.zip,
        region: @params.region,
        country: @params.country
    )
    @artist.company
  end

  private

  def initialize(artist, params)
    @artist = artist
    @params = params
  end
end