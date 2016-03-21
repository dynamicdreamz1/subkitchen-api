describe PaypalHooks::Api, type: :request do
  let(:order){ create(:order, total_cost: 1.00) }
  let(:user){ create(:user, artist: true) }
  let(:user_payment){ create(:payment, payable: user) }
  let(:order_payment){ create(:payment, payable: order) }

  before(:all) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    AdminUser.destroy_all
    create(:admin_user)
    create(:admin_user)
  end

  describe 'USER VERIFICATION' do
    it 'should change artist status' do
      post '/api/v1/user_verify_notification', { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                 "payment_gross"=>"1.00",
                                                 "invoice"=>user_payment.id,
                                                 "payment_status"=>"Completed",
                                                 "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user.status).to eq('verified')
    end

    it 'should status 201' do
      post '/api/v1/user_verify_notification', { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                 "payment_gross"=>"1.00",
                                                 "invoice"=>user_payment.id,
                                                 "payment_status"=>"Completed",
                                                 "txn_id"=>"61E67681CH3238416" }

      expect(response).to have_http_status(:success)
    end

    it 'should change payment status to completed' do
      post '/api/v1/user_verify_notification', { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                 "payment_gross"=>"1.00",
                                                 "invoice"=>user_payment.id,
                                                 "payment_status"=>"Completed",
                                                 "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_status).to eq('completed')
    end

    it 'should have transaction id' do
      post '/api/v1/user_verify_notification', { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                 "payment_gross"=>"1.00",
                                                 "invoice"=>user_payment.id,
                                                 "payment_status"=>"Completed",
                                                 "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_token).to eq('61E67681CH3238416')
    end

    it 'should change payment status to denied' do
      post '/api/v1/user_verify_notification', { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                 "payment_gross"=>"1.00",
                                                 "invoice"=>user_payment.id,
                                                 "payment_status"=>"Denied",
                                                 "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_status).to eq('denied')
    end

    it 'should not change artist status' do
      post '/api/v1/user_verify_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                  "payment_gross"=>"1.00",
                                                  "invoice"=>user_payment.id,
                                                  "payment_status"=>"Denied",
                                                  "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user.status).to eq('unverified')
    end

    it 'should not change order when payment receiver email invalid' do
      expect do
        post '/api/v1/user_verify_notification',  { "receiver_email"=>"invalid receiver email",
                                                  "payment_gross"=>"1.00",
                                                  "invoice"=>user_payment.id,
                                                  "payment_status"=>"Completed",
                                                  "txn_id"=>"61E67681CH3238416" }
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it 'should not change order when payment gross invalid' do
      expect do
        post '/api/v1/user_verify_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                                  "payment_gross"=>"100.00",
                                                  "invoice"=>user_payment.id,
                                                  "payment_status"=>"Completed",
                                                  "txn_id"=>"61E67681CH3238416" }
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it 'should change status to malformed' do
      post '/api/v1/user_verify_notification',  { "receiver_email"=>"invalid receiver email",
                                                  "payment_gross"=>"100.00",
                                                  "invoice"=>user_payment.id,
                                                  "payment_status"=>"Completed",
                                                  "txn_id"=>"61E67681CH3238416" }
      user_payment.reload
      expect(user_payment.payment_status).to eq('malformed')
    end
  end

  describe 'ORDER PAYMENT' do
    it 'should change payment status' do
      post '/api/v1/payment_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                              "payment_gross"=>"1.00",
                                              "invoice"=>order_payment.id,
                                              "payment_status"=>"Completed",
                                              "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_status).to eq('completed')
    end

    it 'should return status 201' do
      post '/api/v1/payment_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                              "payment_gross"=>"1.00",
                                              "invoice"=>order_payment.id,
                                              "payment_status"=>"Completed",
                                              "txn_id"=>"61E67681CH3238416" }

      expect(response).to have_http_status(:success)
    end

    it 'should change order purchased' do
      post '/api/v1/payment_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                              "payment_gross"=>"1.00",
                                              "invoice"=>order_payment.id,
                                              "payment_status"=>"Completed",
                                              "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.purchased).to be_truthy
    end

    it 'should have transaction id' do
      post '/api/v1/payment_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                              "payment_gross"=>"1.00",
                                              "invoice"=>order_payment.id,
                                              "payment_status"=>"Completed",
                                              "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_token).to eq('61E67681CH3238416')
    end

    it 'should set purchased at' do
      new_time = Time.local(2008, 9, 1, 12, 0, 0)
      Timecop.freeze(new_time)

      post '/api/v1/payment_notification',   { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                               "payment_gross"=>"1.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Completed",
                                               "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.purchased_at).to eq(new_time)
    end

    it 'should change order active' do
      post '/api/v1/payment_notification',   { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                               "payment_gross"=>"1.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Completed",
                                               "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.active).to be_falsey
    end

    it 'should change payment status to denied' do
      post '/api/v1/payment_notification',  { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                              "payment_gross"=>"1.00",
                                              "invoice"=>order_payment.id,
                                              "payment_status"=>"Denied",
                                              "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_status).to eq('denied')
    end

    it 'should not change order purchased' do
      post '/api/v1/payment_notification',   { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                               "payment_gross"=>"1.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Denied",
                                               "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.purchased).to be_falsey
    end

    it 'should not change order when receiver email invalid' do
     expect do
       post '/api/v1/payment_notification',   { "receiver_email"=>"invalid receiver email",
                                               "payment_gross"=>"1.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Completed",
                                               "txn_id"=>"61E67681CH3238416" }
     end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it 'should not change order when payment gross invalid' do
      expect do
        post '/api/v1/payment_notification',   { "receiver_email"=>"#{Figaro.env.paypal_seller}",
                                               "payment_gross"=>"2.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Completed",
                                               "txn_id"=>"61E67681CH3238416" }
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it 'should change status to malformed' do
      post '/api/v1/payment_notification',   { "receiver_email"=>"invalid receiver email",
                                               "payment_gross"=>"2.00",
                                               "invoice"=>order_payment.id,
                                               "payment_status"=>"Completed",
                                               "txn_id"=>"61E67681CH3238416" }
      order_payment.reload
      expect(order_payment.payment_status).to eq('malformed')
    end
  end
end