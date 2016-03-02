require 'rails_helper'

RSpec.describe User, type: :model do
  let(:artist){create(:user, artist: true, status: 'verified')}
  let(:user){create(:user)}

  before do
    create(:config, name: 'tax', value: '6.0')
    create(:config, name: 'shipping_cost', value: '7.0')
    create(:config, name: 'shipping_info', value: 'info')
  end

  context 'sales_counter' do
    let(:product){create(:product, author: artist)}
    let(:order){create(:order)}

    it 'should increment sales counter after buying an item' do
      OrderItem.create!(order: order, product: product, quantity: 3)
      payment = create(:payment, payable: order)
      expect do
        ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call
        SalesCounter.drain
      end.to change{artist.sales_count}.by(3)
    end

    it 'should set weekly percentage after buying an item' do
      OrderItem.create!(order: order, product: product, quantity: 3)
      payment = create(:payment, payable: order)
      ConfirmPayment.new(payment, Hashie::Mash.new(payment_status: 'Completed')).call
      SalesCounter.drain
      expect(artist.sales_weekly).to eq(100)
    end
  end

  context 'likes_counter' do
    let(:product){create(:product, author: artist)}

    describe 'like' do
      it 'should increment likes counter' do
        expect do
          LikeProduct.new(product, user).call
          LikesCounter.drain
        end.to change{artist.likes_count}.by(1)
      end

      it 'should set likes weekly percentage' do
        LikeProduct.new(product, user).call
        LikesCounter.drain
        expect(artist.likes_weekly).to eq(100)
      end
    end

    describe 'unlike' do
      it 'should decrement likes counter' do
        LikeProduct.new(product, user).call
        LikesCounter.drain

        expect do
          UnlikeProduct.new(product, user).call
          LikesCounter.drain
        end.to change{artist.likes_count}.by(-1)
      end

      it 'should set likes weekly percentage' do
        LikeProduct.new(product, user).call
        LikesCounter.drain

        UnlikeProduct.new(product, user).call
        LikesCounter.drain
        expect(artist.likes_weekly).to eq(0)
      end
    end
  end
end