require 'rails_helper'

RSpec.describe Payment, type: :model do

  before(:each) do
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