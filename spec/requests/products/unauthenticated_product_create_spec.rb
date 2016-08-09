describe Products::Api, type: :request do
  let(:image) { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  let(:product_template) { create(:product_template) }
  let(:artist) { create(:user, status: 'verified', artist: true) }
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/products' do
    describe 'CREATE product' do

      before(:all) do
        @themes = Config.themes.downcase.split(',')
      end

      context 'when user is unauthenticated' do
        before(:each) do
          @params = { name: 'new_product',
                      product_template_id: product_template.id,
                      description: 'description',
                      preview: image,
                      tags: ['cats', @themes.first],
                      published: false,
											uploaded_image: 'http://image_url' }
          post '/api/v1/products', @params

          @product = Product.last
        end

        it 'should create product with correct data' do
          expect(@product.name).to eq(@params[:name])
          expect(@product.product_template.id).to eq(@params[:product_template_id])
          expect(@product.tag_list).to contain_exactly(@params[:tags][0], @params[:tags][1])
					expect(@product.description).to eq(@product.product_template.description)
					expect(@product.uploaded_image).to eq(@params[:uploaded_image].gsub(/http:/, 'https:'))
        end

        it 'should return created product' do
          serialized_product = ProductSerializer.new(@product).as_json
          expect(response.body).to eq(serialized_product.to_json)
          expect(response).to have_http_status(:success)
          expect(response).to match_response_schema('single_product')
        end

        context 'and try to publish product' do
          before(:each) do
            post '/api/v1/products', name: 'new_product',
                                     product_template_id: product_template.id,
                                     description: 'description',
                                     preview: image,
                                     tags: ['cats', @themes.first],
                                     published: true,
								 										 uploaded_image: 'http://image_url'

            @product = Product.last
          end

          it 'should return error' do
            expect(json['errors']).to eq('base' => ["Validation failed: Published can't be true when you're not an artist"])
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end
end
