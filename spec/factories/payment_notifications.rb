FactoryGirl.define do
  factory :payment_notification do
    params "MyText"
    order_id 1
    status "MyString"
    transaction_id "MyString"
  end
end
