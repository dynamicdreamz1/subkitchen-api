FactoryGirl.define do
  factory :order do
    user { create(:user) }
    uuid SecureRandom.uuid
    email 'test@example.com'
  end
end
