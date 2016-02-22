FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    user_id 1
    product_template
  end
end
