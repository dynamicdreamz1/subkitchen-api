FactoryGirl.define do
  factory :payment do
    payable { create(:order) }
  end
end
