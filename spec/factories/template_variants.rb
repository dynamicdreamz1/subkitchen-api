FactoryGirl.define do
  factory :template_variant do
    color { create(:color) }
    name 'All Over'
    template_color_image { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
    product_template { create(:product_template) }
  end
end
