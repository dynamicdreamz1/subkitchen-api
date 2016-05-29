describe Products::Api, type: :request do
  let(:product) { create(:product) }
  let(:user) { create(:user, artist: false) }

  describe '/api/v1/comments' do
    before(:each) do
      5.times { create(:comment, product: product, user: user, content: 'test comment') }
      @post_params = { comment: { product_id: product.id, content: 'test comment' } }
      @get_params = { product_id: product.id }
    end

    describe 'get list of comments' do
      before(:each) do
        get '/api/v1/comments', @get_params
      end

      it 'should list product comments' do
        comments = Comment.product(product.id).page(1)
        serialized_comments = CommentListSerializer.new(comments).as_json
        expect(response.body).to eq(serialized_comments.to_json)
        expect(response).to match_response_schema('comments')
        expect(response).to have_http_status(:success)
      end
    end

    describe 'create new comment' do
      context 'when user authorized' do
        before(:each) do
          post '/api/v1/comments', @post_params, auth_header_for(user)
        end

        it 'should add comment when authorized' do
          expect(product.comments.count). to eq(6)
          expect(response).to match_response_schema('single_comment')
          expect(response).to have_http_status(:success)
        end
      end

      context 'unauthorized' do
        before(:each) do
          post '/api/v1/comments', @post_params
        end

        it 'should not add comment' do
          expect(json['errors']).to eq('base' => ['401 Unauthorized'])
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
