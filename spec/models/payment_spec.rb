require 'rails_helper'

RSpec.describe User, type: :model do
  let(:artist){create(:user, artist: true, status: 'verified')}
  let(:user){create(:user)}

  before do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    @completed = create(:payment, payment_status: 'completed')
    @denied = create(:payment, payment_status: 'denied')
    @malformed = create(:payment, payment_status: 'malformed')
    @pending = create(:payment, payment_status: 'pending')
  end

  describe 'scopes' do
    it 'should return completed payments' do
      expect(Payment.completed).to contain_exactly(@completed)
    end

    it 'should return denied payments' do
      expect(Payment.denied).to contain_exactly(@denied)
    end

    it 'should return completed payments' do
      expect(Payment.malformed).to contain_exactly(@malformed)
    end

    it 'should return completed payments' do
      expect(Payment.pending).to contain_exactly(@pending)
    end
  end
end