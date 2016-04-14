require 'rails_helper'

RSpec.describe 'Published Counter' do
  let(:artist) { create(:user, artist: true, status: 'verified') }
  let(:user) { create(:user) }
  let(:product) { create(:product, author: artist) }

  describe 'publish' do
    it 'should increment published counter' do
      expect do
        PublishProduct.new(product, artist).call
        PublishedCounter.drain
      end.to change { artist.published_count }.by(1)
    end

    it 'should set weekly percentage' do
      PublishProduct.new(product, artist).call
      PublishedCounter.drain

      expect(artist.published_weekly).to eq(100)
    end
  end

  describe 'unpublish' do
    before(:each) do
      PublishProduct.new(product, artist).call
      PublishedCounter.drain
    end

    it 'should decrement published counter' do
      expect do
        DeleteProduct.new(product).call
        PublishedCounter.drain
      end.to change { artist.published_count }.by(-1)
    end
  end
end
