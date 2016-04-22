describe PaypalHooks::Api, type: :request do
  before(:each) do
    @order = create(:order, total_cost: 1.00)
    @order_payment = create(:payment, payable: @order)
    @valid_order_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => @order.total_cost,
      'invoice' => @order_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416' }
    @denied_order_params = { 'receiver_email' => Figaro.env.paypal_seller.to_s,
                             'payment_gross' => @order.total_cost,
                             'invoice' => @order_payment.id,
                             'payment_status' => 'Denied',
                             'txn_id' => '61E67681CH3238416' }
    @invalid_receiver_order_params = {
      'receiver_email' => 'invalid receiver email',
      'payment_gross' => @order.total_cost,
      'invoice' => @order_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416' }
    @invalid_payment_order_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => '2.00',
      'invoice' => @order_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416' }
  end

  describe 'ORDER PAYMENT' do
    context 'completed' do
      context 'with valid order params' do
        before(:each) do
          post '/api/v1/payment_notification', @valid_order_params
          @order.reload
          @order_payment.reload
        end

        it 'should change payment and order' do
          expect(response).to have_http_status(:success)
          expect(@order_payment.payment_status).to eq('completed')
          expect(@order.purchased).to be_truthy
          expect(@order_payment.payment_token).to eq('61E67681CH3238416')
          expect(@order.active).to be_falsey
        end
      end

      context 'with time freeze' do
        before(:each) do
          @new_time = Time.local(2008, 9, 1, 12, 0, 0)
          Timecop.freeze(@new_time) do
            post '/api/v1/payment_notification', @valid_order_params
            @order.reload
            @order_payment.reload
          end
        end

        it 'should set purchased at' do
          expect(@order.purchased_at).to eq(@new_time)
        end
      end
    end

    context 'denied' do
      before(:each) do
        post '/api/v1/payment_notification', @denied_order_params
        @order.reload
        @order_payment.reload
      end

      it 'should change payment and order' do
        expect(@order_payment.payment_status).to eq('denied')
        expect(@order.purchased).to be_falsey
      end
    end

    context 'malformed' do
      context 'invalid receiver params' do
        before(:each) do
          create(:admin_user)
          post '/api/v1/payment_notification', @invalid_receiver_order_params
          @order_payment.reload
        end

        it 'should notify all admins when receiver email invalid' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should change status to malformed' do
          expect(@order_payment.payment_status).to eq('malformed')
        end
      end

      context 'invalid receiver params' do
        before(:each) do
          create(:admin_user)
          post '/api/v1/payment_notification', @invalid_payment_order_params
          @order_payment.reload
        end

        it 'should notify all admins when receiver email invalid' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should change status to malformed' do
          expect(@order_payment.payment_status).to eq('malformed')
        end
      end
    end
  end
end
