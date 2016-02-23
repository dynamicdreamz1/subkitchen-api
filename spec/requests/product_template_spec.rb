describe ProductTemplates::Api, type: :request do
  describe '/api/v1/product_templates' do
    it 'should create product template' do
      VCR.use_cassette('s3/product_template/valid') do
        user = create(:user)
        size_chart = fixture_file_upload(Rails.root.join("app/assets/images/sizechart-hoodie.jpg"), 'image/jpg')
        post '/api/v1/product_templates', { price: '12345',
                                           product_type: 't_shirt',
                                           size: %(s m l),
                                           size_chart: size_chart}, auth_header_for(user)
        product_template = ProductTemplate.first
        expect(response.body).to eq(product_template.to_json)
        expect(product_template.size_chart_id).to be_truthy
      end
    end
  end

  describe '/api/v1/product_templates/:id' do
    it 'should remove product template' do
      user = create(:user)
      product_template = create(:product_template)
      expect do
        delete "/api/v1/product_templates/#{product_template.id}", {}, auth_header_for(user)
      end.to change(ProductTemplate, :count).by(-1)
    end
  end
end
