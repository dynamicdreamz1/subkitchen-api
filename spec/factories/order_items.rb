FactoryGirl.define do
  factory :order_item do
    product { create(:product) }
    template_variant { create(:template_variant) }
    order { create(:order) }
    quantity 1
    size 's'
  end
end
