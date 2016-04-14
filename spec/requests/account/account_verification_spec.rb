describe Accounts::Api, type: :request do
  let(:artist) { create(:user, artist: true, handle: 'artist') }

  describe '/api/v1/account/verification' do
    context 'with company params' do
      before(:each) do
        @params = {
          has_company: true,
          handle: 'asd',
          company_name: 'elpassion',
          address: 'plac Europejski 6',
          city: 'Warszawa',
          zip: '01-111',
          region: 'mazowieckie',
          country: 'PL',
          return_path: ''
        }
        post '/api/v1/account/verification', @params, auth_header_for(artist)
        artist.reload
      end

      it 'should create Company' do
        expect(artist.company).to be_a Company
      end

      it 'should save company address' do
        expect(@params[:company_name]).to eq(artist.company.company_name)
        expect(@params[:address]).to eq(artist.company.address)
        expect(@params[:zip]).to eq(artist.company.zip)
        expect(@params[:region]).to eq(artist.company.region)
        expect(@params[:city]).to eq(artist.company.city)
        expect(@params[:country]).to eq(artist.company.country)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should return url' do
        payment = Payment.find_by!(payable: artist)

        expect(json['url']).to eq(PaypalUserVerification.new(payment, '').call)
      end

      it 'should change user status' do
        expect(artist.artist).to be_truthy
        expect(artist.pending?).to be_truthy
      end
    end

    context 'with no company params' do
      before(:each) do
        params = { has_company: false, return_path: '', handle: 'asd' }
        post '/api/v1/account/verification', params, auth_header_for(artist)
        artist.reload
      end

      it 'should not create company' do
        expect(artist.company).to be_nil
      end
    end
  end
end
