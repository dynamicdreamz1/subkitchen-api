describe Products::Api, type: :request do
  let(:artist) { create(:user, :artist) }

  describe '/api/v1/products' do
    describe 'list of order items' do

        before(:each) do
          p1 = create(:product, author: artist)
          p2 = create(:product, author: artist)
          p3 = create(:product, author: artist)
          create(:purchased_order_with_items, product: p3, purchased_at: DateTime.now - 1)
          create(:purchased_order_with_items, product: p2, purchased_at: DateTime.now - 2)
          create(:purchased_order_with_items, product: p1, purchased_at: DateTime.now - 3)
        end

      context 'without page params' do
        before(:each) do
          get '/api/v1/order_items', { author_id: artist.id }
        end

        it 'should return first page of products' do
          serialized_items = OrderItemListSerializer.new(OrderItem.last_sales(artist.id).page(1).per(5)).as_json
          expect(response.body).to eq(serialized_items.to_json)
          expect(response).to have_http_status(:success)
          expect(response).to match_response_schema('order_items')
        end
      end

      context 'with page params' do
        before(:each) do
          @params = { author_id: artist.id, page: 2, per_page: 1 }
          get '/api/v1/order_items', @params
          @items = OrderItem.last_sales(artist.id).page(@params[:page]).per(@params[:per_page])
        end

        it 'should return page of order items' do
          expect(response).to match_response_schema('order_items')
          expect(response).to have_http_status(:success)
          serialized_order_items = OrderItemListSerializer.new(@items).as_json
          expect(response.body).to eq(serialized_order_items.to_json)
        end
      end
    end
  end
end
