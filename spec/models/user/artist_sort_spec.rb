RSpec.describe User, type: :model do
  describe 'sort by scope' do
    before(:each) do
      @a1 = create(:user, :artist, created_at: 1.week.ago, likes_count: 1)
      @a2 = create(:user, :artist, created_at: 2.week.ago, likes_count: 2)
      @a3 = create(:user, :artist, created_at: 3.week.ago, likes_count: 3)
    end

    it 'should sort by created_at desc' do
      sorted_artists = User.sort_by('created_at_desc')

      expect(sorted_artists[0]).to eq(@a1)
      expect(sorted_artists[1]).to eq(@a2)
      expect(sorted_artists[2]).to eq(@a3)
    end

    it 'should sort by created_at asc' do
			sorted_artists = User.sort_by('created_at_asc')

      expect(sorted_artists[0]).to eq(@a3)
      expect(sorted_artists[1]).to eq(@a2)
      expect(sorted_artists[2]).to eq(@a1)
		end

		it 'should sort by likes_count desc' do
			sorted_artists = User.sort_by('likes_count_desc')

			expect(sorted_artists[0]).to eq(@a3)
			expect(sorted_artists[1]).to eq(@a2)
			expect(sorted_artists[2]).to eq(@a1)
		end

		it 'should sort by likes_count asc' do
			sorted_artists = User.sort_by('likes_count_asc')

			expect(sorted_artists[0]).to eq(@a1)
			expect(sorted_artists[1]).to eq(@a2)
			expect(sorted_artists[2]).to eq(@a3)
		end
  end
end
