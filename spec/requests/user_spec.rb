describe Accounts::Api, type: :request do
  let(:user) do
    create(:user,
           handle: 'countryjorge',
           first_name: 'Jorge',
           last_name: 'Countryman',
           name: 'Jorge',
           address: 'Slump 14',
           zip: '12340',
           city: 'CountrySide',
           country: 'US')
  end

  describe '/api/v1/users/' do
    context "fetching user by handle" do
      it 'should return user by handle' do
        get '/api/v1/users/', {handle: user.handle}

        expect(response).to have_http_status(:success)
        expect(json['user']['name']).to eq(user.name)
        expect(json['user']['id']).to eq(user.id)
      end

      it 'should raise 404 for unknown handle' do
        get '/api/v1/users/', {handle: 'mom... mom... mooooom....'}

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
