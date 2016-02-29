FactoryGirl.define do
  factory :like do
    likeable_id 1
    likeable_type 'Product'
    user_id 1
  end
end
