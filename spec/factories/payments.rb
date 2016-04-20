FactoryGirl.define do
  factory :payment do
    payable { create(:order) }
    payment_type 'stripe'
  end
end
