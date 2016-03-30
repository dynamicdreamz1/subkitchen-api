describe Sessions::Api, type: :request do
  describe '/api/v1/sessions' do
    describe 'REGISTER by form' do
      it 'should be able to register' do
        params =  { email: 'test@gmail.com',
                    name: 'test',
                    password: 'password',
                    password_confirmation: 'password',
                    artist: 'false' }

        expect do
          post '/api/v1/sessions/register', params
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response).to match_response_schema('user_public')
      end

      it 'should not be able to register with no password' do
        params =  { email: 'test@gmail.com',
                    name: 'test',
                    password: '',
                    password_confirmation: '',
                    artist: 'false' }

        expect do
          post '/api/v1/sessions/register', params
        end.to change(User, :count).by(0)
      end

      it 'should receive email with confirmation link' do
        params = { email: 'test@gmail.com',
                   name: 'test',
                   password: 'password',
                   password_confirmation: 'password',
                   artist: 'false'
        }
        expect do
          post '/api/v1/sessions/register', params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'REGISTER when placing order' do
      before(:each) do
        @order = create(:order)
        @params =  { order_uuid: @order.uuid,
                    first_name: 'John',
                    last_name: 'Doe',
                    address: 'No 14',
                    zip: '00340',
                    city: 'Morgue',
                    country: 'DE',
                    region: '',
                    email: 'test@gmail.com',
                    name: 'test',
                    password: 'password',
                    password_confirmation: 'password',
                    artist: 'false' }
      end
      it 'should be able to register' do
        expect do
          post '/api/v1/sessions/register', @params
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
        expect(response).to match_response_schema('user_public')
      end

      it 'should save user address' do
        post '/api/v1/sessions/register', @params

        user = User.last

        expect(@params[:first_name]).to eq(user.first_name)
        expect(@params[:last_name]).to eq(user.last_name)
        expect(@params[:address]).to eq(user.address)
        expect(@params[:zip]).to eq(user.zip)
        expect(@params[:region]).to eq(user.region)
        expect(@params[:city]).to eq(user.city)
        expect(@params[:country]).to eq(user.country)
      end

      it 'should set new user in order' do
        post '/api/v1/sessions/register', @params

        user = User.last
        @order.reload

        expect(@order.user).to eq(user)
      end
    end
  end
end
