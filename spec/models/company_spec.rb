RSpec.describe Company, type: :model do
  let(:artist){ create(:user, artist: true, status: 'verified') }
  let(:user){ create(:user, artist: false) }

  it 'should create company' do
    company = create(:company, user: artist)
    expect(company.user).to eq(artist)
  end

  it 'should not create company when user is not an artist' do
    expect{ create(:company, user: user) }.to raise_error{ ActiveRecord::RecordInvalid }
  end
end
