FactoryGirl.define do
  factory :product_wish do
    wished_product { create(:product) }
    user { create(:user) }
  end
end
