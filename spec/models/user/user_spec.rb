RSpec.describe User, type: :model do
  let(:user) { create(:user, handle: 'test') }

  it 'should have auth_token' do
    expect(user.auth_token).to_not be_blank
  end

  it 'should have password_reminder_token' do
    expect(user.password_reminder_token).to_not be_blank
  end

  it 'should be able to reset auth_token' do
    expect { user.regenerate_auth_token }.to change(user, :auth_token)
  end

  it 'should have unique name' do
    expect do
      create(:user, name: user.name)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have unique handle' do
    expect do
      create(:user, handle: user.handle)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have unverified status' do
    expect(user.status).to eq('unverified')
  end

  describe 'ChangeStatusIfArtist callback' do
    context 'on create' do
      it 'should change status' do
        user = create(:user, artist: true)
        expect(user.status).to eq('pending')
      end
    end

    context 'on update' do
      it 'should change status' do
        user.update(artist: true)
        expect(user.status).to eq('pending')
      end
    end
  end

  it 'should destroy dependent' do
    product_wish_id = create(:product_wish, user: user).id
    user.destroy

    expect { ProductWish.find(product_wish_id) }.to raise_error(ActiveRecord::RecordNotFound)
	end

	describe 'FeaturedValidator' do
		it 'should not set featured to true when not an artist' do
			expect do
				create(:user, featured: true)
			end.to raise_error(ActiveRecord::RecordInvalid)
		end

		it 'should not set featured to true when not verified' do
			expect do
				create(:user, artist: true, featured: true)
			end.to raise_error(ActiveRecord::RecordInvalid)
		end

		it 'should create user with featured set to true' do
			expect do
				create(:user, :artist, featured: true)
			end.to change(User, :count).by(1)
		end
	end
end
