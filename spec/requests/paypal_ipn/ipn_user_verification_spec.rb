describe PaypalHooks::Api, type: :request do
  before(:each) do
    @user = create(:user, artist: true)
    @user_payment = create(:payment, payable: @user)
    @valid_user_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => '1.00',
      'invoice' => @user_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416'
    }
    @denied_user_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => '1.00',
      'invoice' => @user_payment.id,
      'payment_status' => 'Denied',
      'txn_id' => '61E67681CH3238416'
    }
    @invalid_receiver_user_params = {
      'receiver_email' => 'invalid receiver email',
      'payment_gross' => '1.00',
      'invoice' => @user_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416'
    }
    @invalid_payment_user_params = {
      'receiver_email' => Figaro.env.paypal_seller.to_s,
      'payment_gross' => '100.00',
      'invoice' => @user_payment.id,
      'payment_status' => 'Completed',
      'txn_id' => '61E67681CH3238416'
    }
  end

  describe 'USER VERIFICATION' do
    context 'completed' do
      before(:each) do
        post '/api/v1/user_verify_notification', @valid_user_params
        @user.reload
        @user_payment.reload
      end

      it 'should change user and payment' do
        expect(response).to have_http_status(:success)
        expect(@user.status).to eq('verified')
        expect(@user_payment.payment_status).to eq('completed')
        expect(@user_payment.payment_token).to eq('61E67681CH3238416')
      end
    end

    context 'denied' do
      before(:each) do
        post '/api/v1/user_verify_notification', @denied_user_params
        @user.reload
        @user_payment.reload
      end

      it 'should not change artist status' do
        expect(@user_payment.payment_status).to eq('denied')
        expect(@user.status).to eq('unverified')
      end
    end

    context 'malformed' do
      context 'invalid receiver params' do
        before(:each) do
          create(:admin_user)
          post '/api/v1/user_verify_notification', @invalid_receiver_user_params
          @user_payment.reload
        end

        it 'should notify all admins when receiver email invalid' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should change status to malformed' do
          expect(@user_payment.payment_status).to eq('malformed')
        end
      end

      context 'invalid receiver params' do
        before(:each) do
          create(:admin_user)
          post '/api/v1/payment_notification', @invalid_payment_user_params
          @user_payment.reload
        end

        it 'should notify all admins when receiver email invalid' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        it 'should change status to malformed' do
          expect(@user_payment.payment_status).to eq('malformed')
        end
      end
    end
  end
end
