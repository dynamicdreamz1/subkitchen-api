describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    it 'should be able to authenticate' do
      user = create(:user, password: 'asd')

      post '/api/v1/sessions', email: user.email, password: 'asd'

      expect(response).to have_http_status(:success)
      expect(json["name"]).to eq(user.name)
      expect(json["auth_token"]).to eq(user.auth_token)
    end
  end
end
