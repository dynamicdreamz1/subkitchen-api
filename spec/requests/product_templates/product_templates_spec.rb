describe ProductTemplates::Api, type: :request do
  let(:valid_image) { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  let(:valid_mask) { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  let(:too_big_image) { fixture_file_upload(Rails.root.join('app/assets/images/1920x1080.png'), 'image/png') }
  let(:too_big_mask) { fixture_file_upload(Rails.root.join('app/assets/images/1920x1080.png'), 'image/png') }
  let(:too_small_image) { fixture_file_upload(Rails.root.join('app/assets/images/image.png'), 'image/png') }
  let(:too_small_mask) { fixture_file_upload(Rails.root.join('app/assets/images/image.png'), 'image/png') }

  describe '/api/v1/product_templates' do
    before(:each) do
      create(:product_template, template_image: valid_image, template_mask: valid_mask, size_chart: valid_image)
      get '/api/v1/product_templates'
    end

    it 'should return serialized product templates' do
      serialized_product = ProductTemplateListSerializer.new(ProductTemplate.all).as_json
      expect(response.body).to eq(serialized_product.to_json)
      expect(response).to match_response_schema('product_templates')
      expect(response).to have_http_status(:success)
    end
  end

  describe 'ProductTemplateImageValidator' do
    it 'should upload 1024x1024 image' do
      expect do
        create(:product_template, template_image: valid_image)
      end.not_to raise_error
    end

    it 'should upload 1024x1024 mask' do
      expect do
        create(:product_template, template_mask: valid_mask)
      end.not_to raise_error
    end

    it 'should raise error when width or height is less than 1024' do
      expect do
        create(:product_template, template_image: too_small_image)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should raise error when width or height is less than 1024' do
      expect do
        create(:product_template, template_mask: too_small_mask)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should raise error when width or height is greater than 1024' do
      expect do
        create(:product_template, template_image: too_big_image)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should raise error when width or height is greater than 1024' do
      expect do
        create(:product_template, template_mask: too_big_mask)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
