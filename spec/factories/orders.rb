FactoryGirl.define do
  factory :order do
    user
    uuid SecureRandom.uuid
  end
end
