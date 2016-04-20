RSpec.describe ProductTemplate, type: :model do
  let(:template) { create(:product_template) }
  let(:product1) { create(:product, product_template: template) }
  let(:product2) { create(:product, product_template: template) }

  describe 'UpdateProductPrices on update callback' do
    it 'should update all products after price change' do
      template.update(price: 123)

      product1.reload
      product2.reload
      expect(product1.price).to eq(123)
      expect(product2.price).to eq(123)
    end
  end

  it 'should have attributes' do
    template = ProductTemplate.create

    expect(template.errors[:template_image].present?).to eq(true)
    expect(template.errors[:template_mask].present?).to eq(true)
    expect(template.errors[:price].present?).to eq(true)
    expect(template.errors[:size].present?).to eq(true)
    expect(template.errors[:profit].present?).to eq(true)
    expect(template.errors[:product_type].present?).to eq(true)
  end
end
