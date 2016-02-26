FactoryGirl.define do
  factory :order_item do
    order
    product
    quantity 1
    size 's'
  end
end
