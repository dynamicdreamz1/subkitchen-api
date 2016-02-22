FactoryGirl.define do
  factory :order do
    user
    state :active
    order_type :cart
  end
end
