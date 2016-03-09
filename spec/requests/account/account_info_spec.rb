describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true, handle: 'artist') }
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:invalid_image){ fixture_file_upload(Rails.root.join('app/assets/images/sample.txt'), 'txt') }
  let(:too_small_image){ fixture_file_upload(Rails.root.join('app/assets/images/image.png'), 'image/png') }

  describe '/api/v1/account' do

    describe 'UPDATE user' do

      context 'artist false' do
        it 'should update user info' do
          params = { name: 'test' }

          put "/api/v1/account/name", params, auth_header_for(user)

          user.reload
          expect(user.name).to eq('test')
          expect(response.body).to eq(user.to_json)
        end
      end

      context 'artist true' do
        it 'should update user handle' do
          params =  { handle: 'testtest' }

          put "/api/v1/account/handle", params, auth_header_for(artist)

          artist.reload
          expect(artist.handle).to eq('testtest')
        end
      end

      it 'should send confirmation email after email update' do
        params = { email: 'test@gmail.com' }

        expect do
          put "/api/v1/account/email", params, auth_header_for(user)
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe 'SHIPPING ADDRESS' do
      it 'should add shipping info' do
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

      it 'should empty shipping info' do
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
    end
  end
end
