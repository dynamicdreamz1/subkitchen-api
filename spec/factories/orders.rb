FactoryGirl.define do
  factory :order do
    uuid SecureRandom.uuid
    email 'test@example.com'
  end
end
