include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    description 'description'
    product_template { create(:product_template) }
    uploaded_image 'http://image_url'
    preview { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
    published false
    author { create(:user) }
    uuid SecureRandom.uuid

    trait :published do
      published true
      published_at DateTime.now
      author { create(:user, artist: true, status: :verified) }
    end
  end
end
