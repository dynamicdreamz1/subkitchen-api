FactoryGirl.define do
  factory :order do
    user
    state :active
    uuid SecureRandom.uuid
  end
end
