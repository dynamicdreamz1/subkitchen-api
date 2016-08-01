require 'rails_helper'

RSpec.describe 'Likes Counter' do
  let(:artist) { create(:user, artist: true) }
  let(:user) { create(:user) }
  let(:product) { create(:product, author: artist) }

  describe 'like' do
    it 'should increment likes counter' do
      expect do
        LikeProduct.new(product, user).call
        LikesCounter.drain
      end.to change { artist.product_likes_count }.by(1)
		end

		it 'should increment product likes' do
			expect do
				LikeProduct.new(product, user).call
				LikesCounter.drain
				artist.reload
			end.to change { artist.product_likes }.by(1)
		end

    it 'should set likes weekly percentage' do
      LikeProduct.new(product, user).call
      LikesCounter.drain

      expect(artist.product_likes_weekly).to eq(100)
    end
  end

  describe 'unlike' do
    before(:each) do
      LikeProduct.new(product, user).call
      LikesCounter.drain
			artist.reload
    end

    it 'should decrement likes counter' do
      expect do
        UnlikeProduct.new(product, user).call
        LikesCounter.drain
      end.to change { artist.product_likes_count }.by(-1)
		end

		it 'should decrement product likes' do
			expect do
				UnlikeProduct.new(product, user).call
				LikesCounter.drain
				artist.reload
			end.to change { artist.product_likes }.by(-1)
		end

    it 'should set likes weekly percentage' do
      UnlikeProduct.new(product, user).call
      LikesCounter.drain

      expect(artist.product_likes_weekly).to eq(0)
    end
  end
end
