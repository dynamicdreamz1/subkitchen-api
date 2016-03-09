describe PaypalHooks::Api, type: :request do
  let(:order){ create(:order) }
  let(:user){ create(:user, artist: true) }
  let(:user_payment){ create(:payment, payable: user) }
  let(:order_payment){ create(:payment, payable: order) }

  before(:all) do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  describe 'USER VERIFICATION' do
    it 'should change artist status' do
      post '/api/v1/user_verify_notification', { "mc_gross"=>"1.00", "invoice"=>user_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user.status).to eq('verified')
    end

    it 'should change payment status to completed' do
      post '/api/v1/user_verify_notification', { "mc_gross"=>"1.00", "invoice"=>user_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_status).to eq('completed')
    end

    it 'should have transaction id' do
      post '/api/v1/user_verify_notification', { "mc_gross"=>"1.00", "invoice"=>user_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_token).to eq('61E67681CH3238416')
    end

    it 'should change payment status to denied' do
      post '/api/v1/user_verify_notification', { "mc_gross"=>"1.00", "invoice"=>user_payment.id, "payment_status"=>"Denied", "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user_payment.payment_status).to eq('denied')
    end

    it 'should not change artist status' do
      post '/api/v1/user_verify_notification',  { "mc_gross"=>"1.00", "invoice"=>user_payment.id, "payment_status"=>"Denied", "txn_id"=>"61E67681CH3238416" }

      user.reload
      user_payment.reload

      expect(user.status).to eq('unverified')
    end
  end

  describe 'ORDER PAYMENT' do
    it 'should change payment status' do
      post '/api/v1/payment_notification',  { "mc_gross"=>"1.00", "invoice"=>order_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_status).to eq('completed')
    end

    it 'should change order purchased' do
      post '/api/v1/payment_notification',  { "mc_gross"=>"1.00", "invoice"=>order_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.purchased).to be_truthy
    end

    it 'should have transaction id' do
      post '/api/v1/payment_notification',  { "mc_gross"=>"1.00", "invoice"=>order_payment.id, "payment_status"=>"Completed", "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_token).to eq('61E67681CH3238416')
    end

    it 'should change payment status to denied' do
      post '/api/v1/payment_notification',  { "mc_gross"=>"1.00", "invoice"=>order_payment.id, "payment_status"=>"Denied", "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order_payment.payment_status).to eq('denied')
    end

    it 'should not change order purchased' do
      post '/api/v1/payment_notification',   { "mc_gross"=>"1.00", "invoice"=>order_payment.id, "payment_status"=>"Denied", "txn_id"=>"61E67681CH3238416" }

      order.reload
      order_payment.reload
      expect(order.purchased).to be_falsey
    end
  end
end