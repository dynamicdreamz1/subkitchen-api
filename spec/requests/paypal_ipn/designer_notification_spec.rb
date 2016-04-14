describe PaypalHooks::Api, type: :request do
  before(:each) do
    create(:admin_user)
    order_with_designs = create(:order, total_cost: 1.00,
                                        order_items: [create(:order_item, product: create(:product, design_id: '123'))])
    order_without_designs = create(:order, total_cost: 1.00,
                                           order_items: [create(:order_item, product: create(:product, design_id: nil))])
    @order_with_designs_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => order_with_designs.total_cost,
      'invoice' => create(:payment, payable: order_with_designs).id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416' }
    @order_without_designs_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => order_without_designs.total_cost,
      'invoice' => create(:payment, payable: order_without_designs).id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416' }
  end

  describe 'designer notifications' do
    context 'with designer emails' do
      before(:each) do
        create(:config, name: 'designers', value: 'designer@example.com')
      end

      it 'should notify designer when product has no design' do
        expect do
          post '/api/v1/payment_notification', @order_without_designs_params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should not notify designer when all products have design' do
        expect do
          post '/api/v1/payment_notification', @order_with_designs_params
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    context 'with no designer emails' do
      before(:each) do
        create(:config, name: 'designers', value: '')
      end

      it 'should not notify designer when no designers' do
        expect do
          post '/api/v1/payment_notification', @order_with_designs_params
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end
end
