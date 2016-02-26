describe Accounts::Api, type: :request do
  describe '/api/v1/account' do
    it 'updates user info' do
      user = create(:user)
      params = { name: 'test', email: 'test@gmail.com' }
      put "/api/v1/account/#{user.id}", params, auth_header_for(user)
      user.reload
      expect(user.name).to eq('test')
      expect(user.email).to eq('test@gmail.com')
      expect(response.body).to eq(user.to_json)
    end

    it 'updates user info and handle when artist' do
      user = create(:user, artist: true)
      params =  { name: 'test', email: 'test@gmail.com', handle: 'testtest' }
      put "/api/v1/account/#{user.id}", params, auth_header_for(user)
      user.reload
      expect(user.name).to eq('test')
      expect(user.email).to eq('test@gmail.com')
      expect(user.handle).to eq('testtest')
    end

    it 'can not update handle when artist false' do
      user = create(:user, artist: false)
      params = { name: 'test', email: 'test@gmail.com', handle: 'testtest' }
      put "/api/v1/account/#{user.id}", params, auth_header_for(user)
      user.reload
      expect(user.name).to eq('test')
      expect(user.email).to eq('test@gmail.com')
      expect(user.handle).to eq(user.handle)
    end

    it 'sends confirmation email after email update' do
      user = create(:user)
      params = { name: 'test', email: 'test@gmail.com' }
      expect do
        put "/api/v1/account/#{user.id}", params, auth_header_for(user)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'adds shipping info' do
      user = create(:user)
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

    it 'deletes shipping info' do
      user = create(:user)
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

    it 'should add company address' do
      user = create(:user, artist: true)
      params = {
          company_name: 'elpassion',
          address: 'plac Europejski 6',
          city: 'Warszawa',
          zip: '01-111',
          region: 'mazowieckie',
          country: 'PL'
      }
      post '/api/v1/account/verification', params, auth_header_for(user)
      expect(user.company).to be_a Company
      expect(user.company.company_name).to eq('elpassion')
    end

    it 'should return verification link to paypal' do
      user = create(:user)

      get '/api/v1/account/paypal_verification_url', { return_path: '' }, auth_header_for(user)
      payment = Payment.find_by(payable_id: user.id, payable_type: user.class.name)

      expect(json['url']).to eq(PaypalUserVerification.new(payment, '').call)
    end
  end
end
