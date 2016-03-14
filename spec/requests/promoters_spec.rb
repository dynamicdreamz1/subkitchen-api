describe Promoters::Api, type: :request do
  describe '/api/v1/promoters' do
    it 'returns promoter' do
      user = create(:user)

      get "/api/v1/promoters/#{user.id}"

      expect(response).to have_http_status(:success)
      expect(response.body).to eq(PromoterSerializer.new(user).to_json)
    end
  end
end
