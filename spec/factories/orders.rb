FactoryGirl.define do
  factory :order do
    user
    uuid SecureRandom.uuid
    email 'test@example.com'
  end
end
