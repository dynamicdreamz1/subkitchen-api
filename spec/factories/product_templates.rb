FactoryGirl.define do
  factory :product_template do
    price 19.99
    product_type 't_shirt'
    size %w(s m l xl)
    shipping
    size_chart  { ActionDispatch::Http::UploadedFile.new({
                        :filename => 'sizechart_hoodie.jpg',
                        :type => 'image/jpg',
                        :tempfile => File.new("#{Rails.root}/app/assets/images/sizechart-hoodie.jpg")
                    })}
  end
end
