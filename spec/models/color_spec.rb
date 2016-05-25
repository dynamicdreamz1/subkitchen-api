RSpec.describe Color, type: :model do
  it 'should have name and value' do
    color = Color.create
    expect(color.errors[:name].present?).to eq(true)
    expect(color.errors[:color_value].present?).to eq(true)
  end
end
