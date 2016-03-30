describe PaypalHooks::Api, type: :request do
  before(:each) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    @order = create(:order, total_cost: 1.00)
    @order_payment = create(:payment, payable: @order)

    @valid_order_params =            { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                                       'payment_gross'=>@order.total_cost,
                                       'invoice'=>@order_payment.id,
                                       'payment_status'=>'Completed',
                                       'txn_id'=>'61E67681CH3238416' }
    @denied_order_params =           { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                                       'payment_gross'=>@order.total_cost,
                                       'invoice'=>@order_payment.id,
                                       'payment_status'=>'Denied',
                                       'txn_id'=>'61E67681CH3238416' }
    @invalid_receiver_order_params = { 'receiver_email'=>'invalid receiver email',
                                       'payment_gross'=>@order.total_cost,
                                       'invoice'=>@order_payment.id,
                                       'payment_status'=>'Completed',
                                       'txn_id'=>'61E67681CH3238416' }
    @invalid_payment_order_params =  { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                                       'payment_gross'=>'2.00',
                                       'invoice'=>@order_payment.id,
                                       'payment_status'=>'Completed',
                                       'txn_id'=>'61E67681CH3238416' }
  end

  describe 'ORDER PAYMENT' do

    context 'completed' do

      it 'should change payment status' do
        post '/api/v1/payment_notification',  @valid_order_params

        @order.reload
        @order_payment.reload
        expect(@order_payment.payment_status).to eq('completed')
      end

      it 'should return status 201' do
        post '/api/v1/payment_notification',  @valid_order_params

        expect(response).to have_http_status(:success)
      end

      it 'should change order purchased' do
        post '/api/v1/payment_notification',  @valid_order_params

        @order.reload
        @order_payment.reload
        expect(@order.purchased).to be_truthy
      end

      it 'should have transaction id' do
        post '/api/v1/payment_notification',  @valid_order_params

        @order.reload
        @order_payment.reload
        expect(@order_payment.payment_token).to eq('61E67681CH3238416')
      end

      it 'should set purchased at' do
        new_time = Time.local(2008, 9, 1, 12, 0, 0)
        Timecop.freeze(new_time)

        post '/api/v1/payment_notification',   @valid_order_params

        @order.reload
        @order_payment.reload
        expect(@order.purchased_at).to eq(new_time)
      end

      it 'should change order active' do
        post '/api/v1/payment_notification',   @valid_order_params

        @order.reload
        @order_payment.reload
        expect(@order.active).to be_falsey
      end
    end

    context 'denied' do

      it 'should change payment status to denied' do
        post '/api/v1/payment_notification',  @denied_order_params

        @order.reload
        @order_payment.reload
        expect(@order_payment.payment_status).to eq('denied')
      end

      it 'should not change order purchased' do
        post '/api/v1/payment_notification',   @denied_order_params

        @order.reload
        @order_payment.reload
        expect(@order.purchased).to be_falsey
      end
    end

    context 'malformed' do

      before(:each) do
        create(:admin_user)
      end

      it 'should notify all admins when receiver email invalid' do
        expect do
          post '/api/v1/payment_notification', @invalid_receiver_order_params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should notify all admins when payment gross invalid' do
        expect do
          post '/api/v1/payment_notification', @invalid_payment_order_params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should change status to malformed' do
        post '/api/v1/payment_notification', @invalid_payment_order_params
        @order_payment.reload
        expect(@order_payment.payment_status).to eq('malformed')
      end
    end
  end
end