require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = create(:user)
  end

  it 'should have auth_token' do
    expect(@user.auth_token).to_not be_blank
  end

  it 'should have password_reminder_token' do
    expect(@user.password_reminder_token).to_not be_blank
  end

  it 'should be able to reset auth_token' do
    expect { @user.regenerate_auth_token }.to change(@user, :auth_token)
  end

  it 'should have unique name' do
    create(:user, name: 'test')
    expect do
      create(:user, name: 'test')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have unique handle' do
    create(:user, handle: 'test')
    expect do
      create(:user, handle: 'test')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should have unverified status' do
    user = create(:user, artist: false)
    expect(user.status).to eq('unverified')
  end

  it 'should not be able to become artist when email not confirmed' do
    user = create(:user, artist: false, email_confirmed: false)
    expect do
      user.update!(artist: true)
    end.to raise_error(ActiveRecord::RecordInvalid)
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
        @user.update(artist: true)
        expect(@user.status).to eq('pending')
      end
    end
  end
end
