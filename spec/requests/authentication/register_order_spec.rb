describe Sessions::Api, type: :request do
  describe '/api/v1/register' do
    context 'Register when placing order' do
      before(:each) do
        @order = create(:order)
        @params = { order_uuid: @order.uuid,
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
        post '/api/v1/sessions/register', @params
        @user = User.last
        @order.reload
      end

      it 'should be able to register' do
        expect(User.count).to eq(1)
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end

      it 'should mathc json response schema' do
        expect(response).to match_response_schema('user_public')
      end

      it 'should save user address' do
        expect(@params[:first_name]).to eq(@user.first_name)
        expect(@params[:last_name]).to eq(@user.last_name)
        expect(@params[:address]).to eq(@user.address)
        expect(@params[:zip]).to eq(@user.zip)
        expect(@params[:region]).to eq(@user.region)
        expect(@params[:city]).to eq(@user.city)
        expect(@params[:country]).to eq(@user.country)
      end

      it 'should set new user in order' do
        expect(@order.user).to eq(@user)
      end
    end
  end
end
