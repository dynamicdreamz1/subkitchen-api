FactoryGirl.define do
  factory :admin_user do
    password 'password'
    sequence :email do |n|
      "test.admin#{n}@example.com"
    end
  end
end
