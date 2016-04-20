describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    let(:user) { create(:user, password: 'password') }

    describe '/forgot_password' do
      context 'with existing email' do
        before(:each) do
          post '/api/v1/sessions/forgot_password', email: user.email
        end

        it 'should receive email with link' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should match json schema response' do
          expect(response).to match_response_schema('user_public')
        end
      end

      context 'with invalid email' do
        before(:each) do
          post '/api/v1/sessions/forgot_password', email: 'invalid@email.com'
        end

        it 'should not receive email with link' do
          expect(ActionMailer::Base.deliveries.count).to eq(0)
        end

        it 'should return status not_found' do
          expect(response).to have_http_status(:not_found)
          expect(json['errors']).to eq('base' => ['record not found'])
        end
      end
    end
  end
end
