describe Payments::Api, type: :request do
  describe '/api/v1/orders/:uuid/payment' do
    context 'checkout' do
      before(:each) do
        order = create(:order, user: nil)
        get "/api/v1/orders/#{order.uuid}/payment"
      end

      it 'should match response schema' do
        expect(response).to match_response_schema('checkout')
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'after deleting product' do
      before(:each) do
        order = create(:order, user: nil)
        create(:order_item,
          order: order,
          product: create(:product, template_variant: create(:template_variant, product_template: create(:product_template, price: 12))))
        create(:order_item,
          order: order,
          product: create(:product, template_variant: create(:template_variant, product_template: create(:product_template, price: 30))))
        CalculateOrder.new(order).call
        DeleteProduct.new(Product.last).call

        get "/api/v1/orders/#{order.uuid}/payment"
      end

      it 'should return deleted items' do
        expect(json['deleted_items']).not_to be_nil
      end

      it 'should update items before checkout' do
        expect(json['order']['subtotal'].to_f).to eq(12.0)
      end

      it 'should match response schema' do
        expect(response).to match_response_schema('checkout')
      end

      it 'should return status success' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
