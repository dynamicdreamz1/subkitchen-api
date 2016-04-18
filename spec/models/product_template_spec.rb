RSpec.describe ProductTemplate, type: :model do
  let(:template) { create(:product_template) }
  let(:variant) { create(:template_variant, product_template: template) }
  let(:product1) { create(:product, template_variant: variant) }
  let(:product2) { create(:product, template_variant: variant) }

  describe 'UpdateProductPrices on update callback' do
    it 'should update all products after price change' do
      template.update(price: 123)

      product1.reload
      product2.reload
      expect(product1.price).to eq(123)
      expect(product2.price).to eq(123)
    end
  end
end
