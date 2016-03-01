describe PaypalHooks::Api, type: :request do
  it 'should change artist status' do
    user = create(:user, artist: true)
    payment = create(:payment, payable: user)
    post '/api/v1/user_verify_notification',  {"mc_gross"=>"1.00", "invoice"=>payment.id, "protection_eligibility"=>"Eligible", "address_status"=>"confirmed", "payer_id"=>"BQZEZ4V7JCGXC", "tax"=>"0.00", "address_street"=>"1 Main St", "payment_date"=>"07:15:59 Mar 01, 2016 PST", "payment_status"=>"Completed", "charset"=>"windows-1252", "address_zip"=>"95131", "first_name"=>"subkitchen", "mc_fee"=>"0.33", "address_country_code"=>"US", "address_name"=>"subkitchen subkitchen", "notify_version"=>"3.8", "custom"=>"", "payer_status"=>"verified", "business"=>"subkitchen@sandbox.com", "address_country"=>"United States", "address_city"=>"San Jose", "quantity"=>"1", "verify_sign"=>"Akr1MMsU902V6tQ0i3n75VU-vJKQASKMknbWZJTFzH2icV2aAgLyr5cS", "payer_email"=>"subkitchen-buyer@sandbox.com", "txn_id"=>"0T120516M7258391X", "payment_type"=>"instant", "last_name"=>"subkitchen", "address_state"=>"CA", "receiver_email"=>"subkitchen@sandbox.com", "payment_fee"=>"0.33", "receiver_id"=>"GBYTXP7RLLHBC", "txn_type"=>"web_accept", "item_name"=>"user verifiaction", "mc_currency"=>"USD", "item_number"=>"", "residence_country"=>"US", "test_ipn"=>"1", "handling_amount"=>"0.00", "transaction_subject"=>"", "payment_gross"=>"1.00", "shipping"=>"0.00", "ipn_track_id"=>"5dca7c1842e83"}
    user.reload
    payment.reload
    expect(user.status).to eq('verified')
    expect(payment.status).to eq('Completed')
  end
end