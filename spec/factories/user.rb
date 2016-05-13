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
    sequence :handle do |n|
      "person#{n}"
    end
    first_name 'test first name'
    last_name 'test last name'
    address 'test plac Europejski 6'
    city 'test Warszawa'
    zip '00-885'
    region 'test mazowieckie'
    country 'PL'
    phone '792541588'
    email_confirmed true

    trait :artist do
      artist true
      status :verified
    end
  end
end
