describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true) }

  describe '/api/v1/account' do
    describe 'UPDATE user' do
      context 'artist false' do
        it 'should update user info' do
          params = { name: 'test', email: 'test@gmail.com' }

          put "/api/v1/account/#{user.id}", params, auth_header_for(user)

          user.reload
          expect(user.name).to eq('test')
          expect(user.email).to eq('test@gmail.com')
          expect(response.body).to eq(user.to_json)
        end

        it 'should not update handle' do
          params = { name: 'test', email: 'test@gmail.com', handle: 'testtest' }

          put "/api/v1/account/#{user.id}", params, auth_header_for(user)

          user.reload
          expect(user.name).to eq('test')
          expect(user.email).to eq('test@gmail.com')
          expect(user.handle).to eq(user.handle)
        end
      end

      context 'artist' do
        it 'should update user info and handle' do
          params =  { name: 'test', email: 'test@gmail.com', handle: 'testtest' }

          put "/api/v1/account/#{artist.id}", params, auth_header_for(artist)

          artist.reload
          expect(artist.name).to eq('test')
          expect(artist.email).to eq('test@gmail.com')
          expect(artist.handle).to eq('testtest')
        end
      end

      it 'should send confirmation email after email update' do
        params = { name: 'test', email: 'test@gmail.com' }

        expect do
          put "/api/v1/account/#{user.id}", params, auth_header_for(user)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'SHIPPING ADDRESS' do
      it 'should add shipping info' do
        params = {
            first_name: 'first name',
            last_name: 'last name',
            address: 'plac Europejski 6',
            city: 'Warszawa',
            zip: '00-884',
            region: 'mazowieckie',
            country: 'PL',
            phone: '792541588'
        }

        post '/api/v1/account/address', params, auth_header_for(user)

        user.reload
        expect(response).to have_http_status(:success)
        expect(user.first_name).to eq('first name')
        expect(response.body).to eq(user.to_json)
      end

      it 'should empty shipping info' do
        params = {
            first_name: '',
            last_name: '',
            address: '',
            city: '',
            zip: '',
            region: '',
            country: '',
            phone: ''
        }

        post '/api/v1/account/address', params, auth_header_for(user)

        user.reload
        expect(response).to have_http_status(:success)
        expect(user.first_name).to eq('')
        expect(response.body).to eq(user.to_json)
      end
    end

    describe 'VERIFICATION' do
      it 'should add company address' do
        params = {
            conditions: true,
            company_name: 'elpassion',
            address: 'plac Europejski 6',
            city: 'Warszawa',
            zip: '01-111',
            region: 'mazowieckie',
            country: 'PL'
        }

        post '/api/v1/account/verification', params, auth_header_for(artist)

        expect(artist.company).to be_a Company
        expect(artist.company.company_name).to eq('elpassion')
      end

      it 'should return error' do
        params = { conditions: false }

        post '/api/v1/account/verification', params, auth_header_for(artist)

        expect(json['errors']).to eq({'conditions'=>['must be accepted']})
      end
    end

    describe 'UPDATE company'
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
        expect(artist.company.company_name).to eq('elpassion')
      end

    describe 'PAYPAL' do
      it 'should return verification link to paypal' do
        get '/api/v1/account/paypal_verification_url', { return_path: '' }, auth_header_for(user)

        payment = Payment.find_by(payable_id: user.id, payable_type: user.class.name)
        expect(json['url']).to eq(PaypalUserVerification.new(payment, '').call)
      end
    end
  end
end
