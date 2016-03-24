describe ProductTemplates::Api, type: :request do
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }

  describe '/api/v1/product_templates' do
    it 'should return serialized product templates' do
      create(:product_template, template_image: image, size_chart: image)

      get '/api/v1/product_templates'

      serialized_product = ProductTemplateListSerializer.new(ProductTemplate.all).as_json
      expect(response.body).to eq(serialized_product.to_json)
    end

    it 'should match json schema' do
      create(:product_template, template_image: image, size_chart: image)

      get '/api/v1/product_templates'

      expect(response).to match_response_schema('product_templates')
    end
  end
end
