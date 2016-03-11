describe Accounts::Api, type: :request do
  let(:user){ create(:user) }
  let(:artist){ create(:user, artist: true, handle: 'artist') }
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:invalid_image){ fixture_file_upload(Rails.root.join('app/assets/images/sample.txt'), 'txt') }
  let(:too_small_image){ fixture_file_upload(Rails.root.join('app/assets/images/image.png'), 'image/png') }

  describe '/api/v1/account' do

    describe 'PROFILE IMAGE' do
      it 'should upload profile image' do
        post '/api/v1/account/profile_image', {image: image}, auth_header_for(user)

        user.reload
        expect(user.profile_image_url).not_to be_nil
        expect(json['image_url']).to eq(Figaro.env.app_host+user.profile_image_url(format: :png))
        Refile
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
