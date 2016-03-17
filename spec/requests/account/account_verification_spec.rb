describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true, handle: 'artist') }
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:invalid_image){ fixture_file_upload(Rails.root.join('app/assets/images/sample.txt'), 'txt') }
  let(:too_small_image){ fixture_file_upload(Rails.root.join('app/assets/images/image.png'), 'image/png') }

  describe '/api/v1/account' do

    describe 'VERIFICATION' do

      before do
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
      end

      it 'should add company address' do
        post '/api/v1/account/verification', @params, auth_header_for(artist)

        artist.reload
        expect(artist.company).to be_a Company
        expect(artist.company.company_name).to eq('elpassion')
      end

      it 'should not verify when email not confirmed' do
        artist.update_attribute(:email_confirmed, false)
        post '/api/v1/account/verification', @params, auth_header_for(artist)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq({'base'=>['confirm your email first']})
      end

      it 'should return url' do
        post '/api/v1/account/verification', @params, auth_header_for(artist)

        artist.reload
        payment = Payment.find_by!(payable: artist)
        expect(response).to have_http_status(:success)
        expect(json['url']).to eq(PaypalUserVerification.new(payment, '').call)
      end

      it 'should change user status' do
        post '/api/v1/account/verification', @params, auth_header_for(artist)

        artist.reload
        expect(artist.artist).to be_truthy
        expect(artist.status).to eq('pending')
      end

      it 'should not add company' do
        params = { has_company: false, return_path: '', handle: 'asd' }

        post '/api/v1/account/verification', params, auth_header_for(artist)

        artist.reload
        expect(artist.company).to be_nil
        expect(artist.company).to be_falsey
      end
    end

    describe 'UPDATE COMPANY' do
      it 'should update company address' do
        create(:company, user: artist)
        params = {
            company_name: 'elpassion',
            address: 'plac Europejski 6',
            city: 'Warszawa',
            zip: '01-111',
            region: 'mazowieckie',
            country: 'PL'
        }

        post '/api/v1/account/company_address', params, auth_header_for(artist)

        artist.reload
        expect(response).to have_http_status(:success)
        expect(artist.company.company_name).to eq('elpassion')
      end
    end
  end
end
