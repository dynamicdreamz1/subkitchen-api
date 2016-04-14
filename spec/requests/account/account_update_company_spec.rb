describe Accounts::Api, type: :request do
  let(:artist) { create(:user, artist: true, handle: 'artist') }

  describe '/api/v1/account/company_address' do
    before(:each) do
      create(:company, user: artist)
      @params = {
        company_name: 'elpassion',
        address: 'plac Europejski 6',
        city: 'Warszawa',
        zip: '01-111',
        region: 'mazowieckie',
        country: 'PL'
      }
      post '/api/v1/account/company_address', @params, auth_header_for(artist)
      artist.reload
    end

    it 'should return status success' do
      expect(response).to have_http_status(:success)
    end

    it 'should return company address' do
      expect(json['user']['company']['company_name']).to eq(artist.company.company_name)
      expect(json['user']['company']['address']).to eq(artist.company.address)
      expect(json['user']['company']['zip']).to eq(artist.company.zip)
      expect(json['user']['company']['region']).to eq(artist.company.region)
      expect(json['user']['company']['city']).to eq(artist.company.city)
      expect(json['user']['company']['country']).to eq(artist.company.country)
    end

    it 'should save company address' do
      expect(@params[:company_name]).to eq(artist.company.company_name)
      expect(@params[:address]).to eq(artist.company.address)
      expect(@params[:zip]).to eq(artist.company.zip)
      expect(@params[:region]).to eq(artist.company.region)
      expect(@params[:city]).to eq(artist.company.city)
      expect(@params[:country]).to eq(artist.company.country)
    end
  end
end
