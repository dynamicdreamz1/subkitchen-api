require 'rails_helper'

RSpec.describe Order, type: :model do
  before(:each) do
    @order = create(:order)
    @user = create(:user)
  end

  describe 'scopes' do
    context 'completed scope' do
      it 'should return purchased orders' do
        order = create(:order, purchased: true)
        expect(Order.completed).to contain_exactly(order)
      end
    end

    context 'waiting_products scope' do
      it 'should return all products waiting for design' do
        product = create(:product, design_id: nil)
        create(:order_item, order: @order, product: product)

        expect(Order.waiting_products(@order)).to contain_exactly(product)
      end

      it 'should not return products with design' do
        product = create(:product, design_id: '123')
        create(:order_item, order: @order, product: product)

        expect(Order.waiting_products(@order)).to eq([])
      end
    end
  end

  describe 'SetTaxAndShipping on create callback' do
    it 'should set tax and shipping cost' do
      expect(@order.shipping_cost).to eq(Config.shipping_cost.to_d)
      expect(@order.tax).to eq(Config.tax.to_d)
    end
  end

  context 'status' do
    it 'has default creating status' do
      expect(@order.order_status).to eq('creating')
    end

    context 'after payment confirmation' do
      let(:order){ create(:order) }
      let(:payment){ create(:payment, payable: order) }

      it 'should change status to "processing" when order items have no design' do
        product = create(:product)
        create(:order_item, order: order, product: product)

        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call

        expect(order.order_status).to eq('processing')
      end

      it 'should change status to "cooking" when all order items have design' do
        product = create(:product, design_id: '123123')
        create(:order_item, order: order, product: product)

        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call

        expect(order.order_status).to eq('cooking')
      end
    end

    context 'after updating product design' do
      let(:product1){ create(:product) }
      let(:product2){ create(:product) }
      let(:order){ create(:order, order_status: 'processing') }

      it 'should change status to "cooking" when all order items have design' do
        create(:order_item, order: order, product: product1)

        product1.update(design_id: '123123')

        order.reload
        expect(order.order_status).to eq('cooking')
      end

      it 'should not change status when design is not updated' do
        create(:order_item, order: order, product: product1)

        product1.update(name: 'new_name')

        order.reload
        expect(order.order_status).to eq('processing')
      end

      it 'should not change status when not all order items have design' do
        create(:order_item, order: order, product: product1)
        create(:order_item, order: order, product: product2)

        product1.update(design_id: '123123')

        order.reload
        expect(order.order_status).to eq('processing')
      end
    end
  end

  describe 'AddressValidator' do
    it 'should not update address when payment completed' do
      payment = create(:payment, payable: @order)

      expect do
        @order.update!(address: 'abcd')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
