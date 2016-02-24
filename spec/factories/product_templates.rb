FactoryGirl.define do
  factory :product_template do
    price 19.99
    product_type 't_shirt'
    size %w(s m l xl)
    size_chart_id '1234'
  end
end
