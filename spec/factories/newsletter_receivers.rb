FactoryGirl.define do
  factory :newsletter_receiver do
    sequence :email do |n|
      "person#{n}@example.com"
    end
  end
end
