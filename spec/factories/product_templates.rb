FactoryGirl.define do
  factory :product_template do
    price 19.99
    product_type 't_shirt'
    size %w(s m l xl)
    size_chart_id '1234'
		description 'abcd'
    template_image { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
    template_mask { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  end
end
