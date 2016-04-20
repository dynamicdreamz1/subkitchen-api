include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    description 'description'
    product_template { create(:product_template) }
    image { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
    published false
    author { create(:user) }
    uuid SecureRandom.uuid

    trait :published do
      published true
      author { create(:user, artist: true, status: :verified) }
    end
  end
end
