include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    description 'description'
    author { create(:user) }
    product_template { create(:product_template) }
    image { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
    price 1
    published false
    uuid SecureRandom.uuid
  end
end
