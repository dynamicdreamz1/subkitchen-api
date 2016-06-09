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
                      image: image,
                      preview: image,
                      tags: ['cats', @themes.first],
                      published: false }
          post '/api/v1/products', @params

          @product = Product.last
        end

        it 'should create product with correct data' do
          expect(@product.name).to eq(@params[:name])
          expect(@product.description).to eq(@params[:description])
          expect(@product.product_template.id).to eq(@params[:product_template_id])
          expect(@product.tag_list).to contain_exactly(@params[:tags][0], @params[:tags][1])
          expect(@product.image_id).to be_truthy
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
                                     image: image,
                                     preview: image,
                                     tags: ['cats', @themes.first],
                                     published: true

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
