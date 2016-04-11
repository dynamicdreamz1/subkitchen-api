RSpec.describe Order, type: :model do
  let(:order){ create(:order) }
  let(:no_design_product){ create(:product) }
  let(:design_product){ create(:product, design_id: '123') }
  let(:product1){ create(:product) }
  let(:product2){ create(:product) }
  let(:processing_order){ create(:order, order_status: 'processing') }

  describe 'status' do

    it 'has default creating status' do
      expect(order.order_status).to eq('creating')
    end

    context 'after payment confirmation' do
      let(:payment){ create(:payment, payable: order) }

      it 'should change status to "processing" when order items have no design' do
        create(:order_item, order: order, product: no_design_product)

        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call

        expect(order.order_status).to eq('processing')
      end

      it 'should change status to "cooking" when all order items have design' do
        create(:order_item, order: order, product: design_product)

        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call

        expect(order.order_status).to eq('cooking')
      end
    end

    context 'after updating product design' do
      before(:each) do
        create(:order_item, order: processing_order, product: product1)
      end

      it 'should change status to "cooking" when all order items have design' do
        product1.update(design_id: '123123')

        processing_order.reload
        expect(processing_order.order_status).to eq('cooking')
      end

      it 'should not change status when design is not updated' do
        product1.update(name: 'new_name')

        order.reload
        expect(processing_order.order_status).to eq('processing')
      end

      it 'should not change status when not all order items have design' do
        create(:order_item, order: processing_order, product: product2)

        product1.update(design_id: '123123')

        order.reload
        expect(processing_order.order_status).to eq('processing')
      end
    end
  end
end
