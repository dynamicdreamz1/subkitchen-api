describe Accounts::Api, type: :request do
  let(:user){ create(:user,
                     first_name: 'Jorge',
                     last_name: 'Countryman',
                     address: 'Slump 14',
                     zip: '12340',
                     city: 'CountrySide',
                     country: 'US') }

  describe '/api/v1/address' do
    it 'should be able to get address' do

      get '/api/v1/addresses/current', {}, auth_header_for(user)

      expect(response).to have_http_status(:success)
      expect(json['address']['first_name']).to eq(user.first_name)
      expect(json['address']['last_name']).to eq(user.last_name)
      expect(json['address']['address']).to eq(user.address)
      expect(json['address']['zip']).to eq(user.zip)
      expect(json['address']['region']).to eq(user.region)
      expect(json['address']['city']).to eq(user.city)
      expect(json['address']['country']).to eq(user.country)
    end

    it 'should be able to save address' do
      params = { address:
                 { first_name: 'John',
                   last_name: 'Doe',
                   address: 'No 14',
                   zip: '00340',
                   city: 'Morgue',
                   country: 'DE' }}

      put '/api/v1/addresses/current', params , auth_header_for(user)

      user.reload

      expect(response).to have_http_status(:success)
      expect(json['address']['first_name']).to eq(user.first_name)
      expect(json['address']['last_name']).to eq(user.last_name)
      expect(json['address']['address']).to eq(user.address)
      expect(json['address']['zip']).to eq(user.zip)
      expect(json['address']['region']).to eq(user.region)
      expect(json['address']['city']).to eq(user.city)
      expect(json['address']['country']).to eq(user.country)

      expect(params[:address][:first_name]).to eq(user.first_name)
      expect(params[:address][:last_name]).to eq(user.last_name)
      expect(params[:address][:address]).to eq(user.address)
      expect(params[:address][:zip]).to eq(user.zip)
      expect(params[:address][:region]).to eq(user.region)
      expect(params[:address][:city]).to eq(user.city)
      expect(params[:address][:country]).to eq(user.country)
    end

  end
end
