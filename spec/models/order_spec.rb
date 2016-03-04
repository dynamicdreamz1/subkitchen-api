require 'rails_helper'

RSpec.describe Order, type: :model do
  before do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
    @order = create(:order)
    @user = create(:user)
  end

  context 'status' do
    it 'has default creating status' do
      expect(@order.order_status).to eq('creating')
    end

    it 'should change status after creating payment' do
      CreatePayment.new(@order).call

      expect(@order.order_status).to eq('payment pending')
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
end
