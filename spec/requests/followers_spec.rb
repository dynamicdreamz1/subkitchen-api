describe Followers::Api, type: :request do
  context 'toggle like' do
    context 'when followed is an artist' do
      before(:each) do
        @artist = create(:user, artist: true, status: :verified)
        @user = create(:user)
        post "/api/v1/users/#{@artist.id}/toggle_follow", {}, auth_header_for(@user)
      end

      it 'should create like (follow)' do
        expect(response).to have_http_status(:success)
        expect(Like.count).to eq(1)
      end

      it 'should return followers/followings' do
        expect(json['artist_followers']).to eq(User.followers(@artist).count)
        expect(json['current_user_followings']).to eq(User.followings(@user).count)
      end

      it 'should delete like (unfollow)' do
        post "/api/v1/users/#{@artist.id}/toggle_follow", {}, auth_header_for(@user)
        expect(Like.count).to eq(0)
      end
    end

    context 'when followed is not an artist' do
      before(:each) do
        @user = create(:user)
        post "/api/v1/users/#{create(:user).id}/toggle_follow", {}, auth_header_for(@user)
      end

      it 'should not create like' do
        expect(Like.count).to eq(0)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq('base' => ['Validation failed: User cannot be followed'])
      end
    end

    context 'followed and follower are same user' do
      before(:each) do
        @user = create(:user)
        post "/api/v1/users/#{@user.id}/toggle_follow", {}, auth_header_for(@user)
      end

      it 'should not create like' do
        expect(Like.count).to eq(0)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['errors']).to eq('base' => ['Validation failed: User cannot follow yourself'])
      end
    end
  end

  context 'when artist is followed' do
    before(:each) do
      @artist = create(:user, artist: true, status: :verified)
      2.times { Like.create(likeable: @artist, user: create(:user)) }
      get "/api/v1/users/#{@artist.id}/followers"
      @artist.reload
    end

    it 'should return list of followers/followings' do
      expect(User.followers(@artist).count).to eq(2)
      expect(User.followings(@artist).count).to eq(0)
      expect(json['followers']).to eq(User.followers(@artist).as_json)
      expect(json['followings']).to eq(User.followings(@artist).as_json)
      expect(response).to have_http_status(:success)
    end
  end

  context 'when user is follower' do
    before(:each) do
      @user = create(:user)
      2.times { create(:like, likeable: create(:user, artist: true, status: :verified), user: @user) }
      get "/api/v1/users/#{@user.id}/followers"
    end

    it 'should return list of followers/followings' do
      expect(User.followers(@user).count).to eq(0)
      expect(User.followings(@user).count).to eq(2)
      expect(json['followers']).to eq([])
      expect(json['followings']).to eq(User.followings(@user).as_json)
      expect(response).to have_http_status(:success)
    end
  end
end
