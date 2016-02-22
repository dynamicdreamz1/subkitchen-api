FactoryGirl.define do
  factory :user_verify_notification do
    params "MyText"
    user_id 1
    status "MyString"
    transaction_id "MyString"
  end
end
