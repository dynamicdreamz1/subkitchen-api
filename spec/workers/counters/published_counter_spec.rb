require 'rails_helper'

RSpec.describe 'Published Counter' do
  let(:product_template) { create(:product_template) }
  let(:artist) { create(:user, artist: true, status: 'verified') }
  let(:user) { create(:user) }
  let(:product) { create(:product, author: artist) }

  describe 'publish' do
    context 'after publish' do
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

    context 'after create' do
      before(:each) do
        temp = fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png')
        image = Hashie::Mash.new(filename: "1024x1024.png",
                         tempfile: temp.tempfile,
                         type: "image/png")
        @params = Hashie::Mash.new(name: 'new_product',
                    product_template_id: product_template.id,
                    description: 'description',
                    uploaded_image: 'http://image_url',
                    preview: image,
                    published: true)
      end

      it 'should increment published counter' do
        expect do
          CreateProduct.new(@params, artist).call
          PublishedCounter.drain
        end.to change { artist.published_count }.by(1)
      end

      it 'should set weekly percentage' do
        CreateProduct.new(@params, artist).call
        PublishedCounter.drain
        expect(artist.published_weekly).to eq(100)
      end
    end
  end

  context 'after update' do
    before(:each) do
      product.update(published_at: DateTime.now)
      @params = Hashie::Mash.new(name: 'new_product', published: true)
    end

    it 'should increment published counter' do
      expect do
        UpdateProduct.new(product.id, @params, artist).call
        PublishedCounter.drain
      end.to change { artist.published_count }.by(1)
    end

    it 'should set weekly percentage' do
      UpdateProduct.new(product.id, @params, artist).call
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
