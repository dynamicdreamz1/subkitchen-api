require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = create(:user)
  end

  it 'has auth_token' do
    expect(@user.auth_token).to_not be_blank
  end

  it 'has password_reminder_token' do
    expect(@user.password_reminder_token).to_not be_blank
  end

  it 'can reset auth_token' do
    expect { @user.regenerate_auth_token }.to change(@user, :auth_token)
  end
end
