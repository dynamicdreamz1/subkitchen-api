FactoryGirl.define do
  factory :user do
    artist true
    password 'password'
    sequence :name do |n|
      "person#{n}"
    end
    sequence :email do |n|
      "person#{n}@example.com"
    end
  end
end
