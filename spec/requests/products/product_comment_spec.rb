describe Products::Api, type: :request do
  let(:product){ create(:product) }
  let(:user){ create(:user, artist: false) }

  describe '/api/v1/comments' do

    before do
      5.times{ create(:comment, product: product, user: user) }
      @post_params = {product_id: product.id, content: 'test comment'}
      @get_params = {product_id: product.id}
    end

    describe 'GET' do
      it 'should list product comments' do
        get '/api/v1/comments', @get_params

        comments = Comment.product(product.id).page(1)
        serialized_comments = CommentListSerializer.new(comments).as_json
        expect(response.body).to eq(serialized_comments.to_json)
      end

      it 'should match json schema' do
        get '/api/v1/comments', @get_params

        expect(response).to match_response_schema('comments')
      end

      it 'should return status success' do
        5.times{ create(:comment, product: product, user: user, content: 'test comment') }
        get '/api/v1/comments', @get_params

        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST' do
      context 'authorized' do
        it 'should match json schema' do
          post '/api/v1/comments', @post_params, auth_header_for(user)

          expect(response).to match_response_schema('single_comment')
        end

        it 'should add comment when authorized' do
          expect do
            post '/api/v1/comments', @post_params, auth_header_for(user)
          end.to change(product.comments, :count).by(1)
        end

        it 'should return status success' do
          post '/api/v1/comments', @post_params, auth_header_for(user)

          expect(response).to have_http_status(:success)
        end
      end

      context 'unauthorized' do
        it 'should not add comment' do
          post '/api/v1/comments', @post_params

          expect(json['errors']).to eq('base'=> ['401 Unauthorized'])
        end

        it 'should return status unauthorized' do
          post '/api/v1/comments', @post_params

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
