require 'rails_helper'

RSpec.describe Like, type: :model do
  before do
    @artist = create(:user, artist: true)
    @user = create(:user, artist: false)
    @product = create(:product, author: @user)
  end

  it 'should create like' do
    expect do
      create(:like, likeable: create(:product), user: @artist)
    end.to change(Like, :count).by(1)
  end

  it 'should raise error when product author and user are same' do
    expect do
      create(:like, likeable: create(:product, author: @artist), user: @artist)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should raise error when product already liked' do
    create(:like, likeable: @product, user: @artist)

    expect do
      create(:like, likeable: @product, user: @artist)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should raise error when product already liked' do
    create(:like, likeable: @product, uuid: '1234')

    expect do
      create(:like, likeable: @product, uuid: '1234')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
