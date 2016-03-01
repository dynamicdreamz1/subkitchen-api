class CompanyAddress
  def call
    company.update(
        company_name: params.company_name,
        address: params.address,
        city: params.city,
        zip: params.zip,
        region: params.region,
        country: params.country
    )
  end

  private

  attr_accessor :artist, :params

  def initialize(artist, params)
    @artist = artist
    @params = params
  end

  def company
    artist.company || artist.create_company
  end
end
