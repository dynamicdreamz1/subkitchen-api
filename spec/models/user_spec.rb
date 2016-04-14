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
end
