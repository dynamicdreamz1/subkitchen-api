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
  end
end
