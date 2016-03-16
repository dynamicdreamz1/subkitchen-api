require 'rails_helper'

RSpec.describe ProductTemplate, type: :model do
  let(:template){ create(:product_template) }

  describe 'UpdateProductPrices on update callback' do
    it 'should update all products after price change' do
      product1 = create(:product, product_template: template)
      product2 = create(:product, product_template: template)

      template.update(price: 123)

      product1.reload
      product2.reload
      expect(product1.price).to eq(123)
      expect(product2.price).to eq(123)
    end
  end
end
