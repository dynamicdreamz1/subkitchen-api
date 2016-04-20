FactoryGirl.define do
  factory :like do
    uuid SecureRandom.uuid
    likeable { create(:product) }
  end
end
