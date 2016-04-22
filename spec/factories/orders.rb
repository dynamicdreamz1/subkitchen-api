FactoryGirl.define do
  factory :order do
    uuid SecureRandom.uuid
    email 'test@example.com'

    factory :order_with_items do
      transient do
        order_items_count 5
      end
      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.order_items_count, order: order)
        CalculateOrder.new(order).call
      end
    end
  end
end
