FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    description 'description'
    author { create(:user) }
    product_template {create(:product_template)}
    price 1
    image_id '1234'
    published false
  end
end
