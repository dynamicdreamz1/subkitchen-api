require 'rails_helper'

RSpec.describe Company, type: :model do
  before do
    @artist = create(:user, artist: true)
    @user = create(:user, artist: false)
  end

  it 'should create company' do
    company = create(:company, user: @artist)
    expect(company.user).to eq(@artist)
  end

  it 'should not create company' do
    expect{ create(:company, user: @user) }.to raise_error{ ActiveRecord::RecordInvalid }
  end
end
