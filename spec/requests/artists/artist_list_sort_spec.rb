describe Artists::Api, type: :request do
	describe '/api/v1/products' do
		context 'sort' do
			before(:each) do
				create(:user, :artist)
				create(:user, :artist)
				create(:user, :artist)
			end
			
			it 'should sort by created_at param desc' do
				get '/api/v1/users', sorted_by: 'created_at_desc', per_page: 3
				
				sorted_artists = User.sort_by('created_at_desc').page(1).per(3)
				serialized_artists = ArtistListSerializer.new(sorted_artists).as_json
				expect(response.body).to eq(serialized_artists.to_json)
			end
			
			it 'should sort by created_at param asc' do
				get '/api/v1/users', sorted_by: 'created_at_asc', per_page: 3
				
				sorted_artists = User.sort_by('created_at_asc').page(1).per(3)
				serialized_artists = ArtistListSerializer.new(sorted_artists).as_json
				expect(response.body).to eq(serialized_artists.to_json)
			end

			it 'should raise error' do
				expect do
					get '/api/v1/users', sorted_by: 'invalid'
				end.to raise_error(ArgumentError)
			end
		end
	end
end
