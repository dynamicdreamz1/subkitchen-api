describe PaypalHooks::Api, type: :request do
  before(:each) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    @user = create(:user, artist: true)
    @user_payment = create(:payment, payable: @user)
    @valid_user_params = { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                           'payment_gross'=>'1.00',
                           'invoice'=>@user_payment.id,
                           'payment_status'=>'Completed',
                           'txn_id'=>'61E67681CH3238416' }
    @denied_user_params =            { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                                       'payment_gross'=>'1.00',
                                       'invoice'=>@user_payment.id,
                                       'payment_status'=>'Denied',
                                       'txn_id'=>'61E67681CH3238416' }
    @invalid_receiver_user_params =  { 'receiver_email'=>'invalid receiver email',
                                       'payment_gross'=>'1.00',
                                       'invoice'=>@user_payment.id,
                                       'payment_status'=>'Completed',
                                       'txn_id'=>'61E67681CH3238416' }
    @invalid_payment_user_params =   { 'receiver_email'=>"#{Figaro.env.paypal_seller}",
                                       'payment_gross'=>'100.00',
                                       'invoice'=>@user_payment.id,
                                       'payment_status'=>'Completed',
                                       'txn_id'=>'61E67681CH3238416' }
  end

  describe 'USER VERIFICATION' do

    context 'completed' do

      it 'should change artist status' do
        post '/api/v1/user_verify_notification', @valid_user_params

        @user.reload
        @user_payment.reload

        expect(@user.status).to eq('verified')
      end

      it 'should status 201' do
        post '/api/v1/user_verify_notification', @valid_user_params

        expect(response).to have_http_status(:success)
      end

      it 'should change payment status to completed' do
        post '/api/v1/user_verify_notification', @valid_user_params

        @user.reload
        @user_payment.reload

        expect(@user_payment.payment_status).to eq('completed')
      end

      it 'should have transaction id' do
        post '/api/v1/user_verify_notification', @valid_user_params

        @user.reload
        @user_payment.reload

        expect(@user_payment.payment_token).to eq('61E67681CH3238416')
      end
    end

    context 'denied' do

      it 'should change payment status to denied' do
        post '/api/v1/user_verify_notification', @denied_user_params

        @user.reload
        @user_payment.reload

        expect(@user_payment.payment_status).to eq('denied')
      end

      it 'should not change artist status' do
        post '/api/v1/user_verify_notification',  @denied_user_params

        @user.reload
        @user_payment.reload

        expect(@user.status).to eq('unverified')
      end
    end

    context 'malformed' do

      before(:each) do
        create(:admin_user)
      end

      it 'should not change order when payment receiver email invalid' do
        expect do
          post '/api/v1/user_verify_notification',  @invalid_receiver_user_params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should not change order when payment gross invalid' do
        expect do
          post '/api/v1/user_verify_notification',  @invalid_payment_user_params
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'should change status to malformed' do
        post '/api/v1/user_verify_notification',  @invalid_receiver_user_params
        @user_payment.reload
        expect(@user_payment.payment_status).to eq('malformed')
      end
    end
  end
end