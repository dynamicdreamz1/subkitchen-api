FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    user
  end
end
