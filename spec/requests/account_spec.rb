describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true) }
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

      context 'artist' do
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

    describe 'VERIFICATION' do
      it 'should add company address' do
        params = {
            has_company: true,
            company_name: 'elpassion',
            address: 'plac Europejski 6',
            city: 'Warszawa',
            zip: '01-111',
            region: 'mazowieckie',
            country: 'PL'
        }

        post '/api/v1/account/verification', params, auth_header_for(artist)

        artist.reload
        expect(artist.company).to be_a Company
        expect(artist.has_company).to be_truthy
        expect(artist.company.company_name).to eq('elpassion')
      end

      it 'should not add company' do
        params = { has_company: false }

        post '/api/v1/account/verification', params, auth_header_for(artist)

        artist.reload
        expect(artist.company).to be_nil
        expect(artist.company).to be_falsey
      end
    end

    describe 'UPDATE company'
      it 'should update company address' do
        create(:company, user: artist)
        params = {
            company_name: 'elpassion',
            address: 'plac Europejski 6',
            city: 'Warszawa',
            zip: '01-111',
            region: 'mazowieckie',
            country: 'PL'
        }

        post '/api/v1/account/company_address', params, auth_header_for(artist)

        artist.reload
        expect(artist.company.company_name).to eq('elpassion')
      end

    describe 'PAYPAL' do
      it 'should return verification link to paypal' do
        get '/api/v1/account/paypal_verification_url', { return_path: '' }, auth_header_for(user)

        payment = Payment.find_by(payable_id: user.id, payable_type: user.class.name)
        expect(json['url']).to eq(PaypalUserVerification.new(payment, '').call)
      end
    end

    describe 'PROFILE IMAGE' do
      it 'should upload profile image' do
        post '/api/v1/account/profile_image', {image: image}, auth_header_for(user)

        user.reload
        expect(user.profile_image_url).not_to be_nil
        expect(json['profile_image_url']).to eq(user.profile_image_url)
      end

      it 'should not upload profile image when invalid type' do
        post '/api/v1/account/profile_image', {image: invalid_image}, auth_header_for(user)

        expect(json['errors']).to eq({'profile_image'=>['has an invalid file format']})
      end

      it 'should not upload profile image when image too small' do
        post '/api/v1/account/profile_image', {image: too_small_image}, auth_header_for(user)

        expect(json['errors']).to eq({'base'=>['image is too small']})
      end
    end

    describe 'SHOP BANNER' do
      it 'should upload banner' do
        post '/api/v1/account/shop_banner', {banner: image}, auth_header_for(artist)
        expect(artist.profile_image_url).not_to be_nil
        artist.reload
        expect(json['shop_banner_url']).to eq(artist.shop_banner_url)
      end

      it 'should not upload banner when artist false' do
        post '/api/v1/account/shop_banner', {banner: image}, auth_header_for(user)

        expect(json['errors']).to eq({'base'=>['user must be an artist']})
      end

      it 'should not upload banner when invalid type' do
        post '/api/v1/account/shop_banner', {banner: invalid_image}, auth_header_for(artist)

        expect(json['errors']).to eq({'shop_banner'=>['has an invalid file format']})
      end

      it 'should not upload profile image when image too small' do
        post '/api/v1/account/shop_banner', {banner: too_small_image}, auth_header_for(artist)

        expect(json['errors']).to eq({'base'=>['image is too small']})
      end
    end
  end
end
