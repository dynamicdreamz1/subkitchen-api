FactoryGirl.define do
  factory :order do
    user
    state :active
    shipping
  end
end
