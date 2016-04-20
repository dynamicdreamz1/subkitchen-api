describe Sessions::Api, type: :request do
  let(:user) { create(:user) }

  describe '/api/v1/confirm_email' do
    context 'with valid token' do
      before(:each) do
        post '/api/v1/sessions/confirm_email', confirm_token: user.confirm_token
        user.reload
      end

      it 'should update email_confirmed to true' do
        expect(user.email_confirmed).to be_truthy
        expect(response).to match_response_schema('user_public')
      end
    end

    context 'with invalid token' do
      before(:each) do
        post '/api/v1/sessions/confirm_email', confirm_token: '1234567890'
        user.reload
      end

      it 'should return error' do
        expect(json['errors']).to eq('base' => ['invalid confirmation token'])
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
