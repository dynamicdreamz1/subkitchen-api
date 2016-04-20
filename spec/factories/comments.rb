FactoryGirl.define do
  factory :comment do
    content 'test comment'
    product { create(:product) }
    user { create(:user) }
  end
end
