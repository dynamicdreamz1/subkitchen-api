describe Users::Api, type: :request do
  let(:user) { create(:user) }

  it 'should return current user' do
    get '/api/v1/users/current', {}, auth_header_for(user)

    expect(response).to have_http_status(:success)
    expect(response.body).to eq(user.to_json)
  end

  it 'should return user by id' do
    get "/api/v1/users/#{user.id}"

    expect(response).to have_http_status(:success)
    expect(response.body).to eq(UserPublicSerializer.new(user).as_json.to_json)
    expect(json['user']['id']).to eq(user.id)
  end

  describe 'user update' do

    it 'should update user information and send email confirmation' do
      params = {
          user: {
              name: 'Jon',
              email: 'john_doe@example.com',
              handle: 'john_doe',
              location: 'USA',
              website: 'johndoe.com',
              bio: '...'
          }}
      put "/api/v1/users/#{user.id}", params, auth_header_for(user)

      user.reload
      expect(response).to have_http_status(:success)
      expect(json['user']['name']).to eq(user.name)
      expect(json['user']['email']).to eq(user.email)
      expect(json['user']['handle']).to eq(user.handle)
      expect(json['user']['location']).to eq(user.location)
      expect(json['user']['website']).to eq(user.website)
      expect(json['user']['bio']).to eq(user.bio)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should not send email confirmation' do
      put "/api/v1/users/#{user.id}", {}, auth_header_for(user)

      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
