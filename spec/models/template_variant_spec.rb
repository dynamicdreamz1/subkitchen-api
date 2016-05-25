RSpec.describe TemplateVariant, type: :model do
  it 'should have attributes' do
    variant = TemplateVariant.create

    expect(variant.errors[:name].present?).to eq(true)
    expect(variant.errors[:color_id].present?).to eq(true)
    expect(variant.errors[:product_template_id].present?).to eq(true)
  end
end
