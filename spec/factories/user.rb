FactoryGirl.define do
  factory :user do
    password 'password'
    sequence :name do |n|
      "person#{n}"
    end
    sequence :email do |n|
      "person#{n}@example.com"
    end
    artist false
  end
end
