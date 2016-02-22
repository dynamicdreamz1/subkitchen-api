FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    author { create(:user) }
    product_template
  end
end
