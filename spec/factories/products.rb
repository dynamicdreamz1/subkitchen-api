FactoryGirl.define do
  factory :product do
    sequence :name do |n|
      "product#{n}"
    end
    description 'description'
    author { create(:user) }
    product_template {create(:product_template)}
    price 1
    image { ActionDispatch::Http::UploadedFile.new({
                                                       :filename => 'sizechart_hoodie.jpg',
                                                       :type => 'image/jpg',
                                                       :tempfile => File.new("#{Rails.root}/app/assets/images/sizechart-hoodie.jpg")
                                                   })}
  end
end
