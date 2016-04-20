RSpec.describe Payment, type: :model do
  let(:completed) { create(:payment, payment_status: 'completed') }
  let(:denied) { create(:payment, payment_status: 'denied') }
  let(:malformed) { create(:payment, payment_status: 'malformed') }
  let(:pending) { create(:payment, payment_status: 'pending') }

  describe 'scopes' do
    it 'should return completed payments' do
      expect(Payment.completed).to contain_exactly(completed)
    end

    it 'should return denied payments' do
      expect(Payment.denied).to contain_exactly(denied)
    end

    it 'should return completed payments' do
      expect(Payment.malformed).to contain_exactly(malformed)
    end

    it 'should return completed payments' do
      expect(Payment.pending).to contain_exactly(pending)
    end
  end

  it 'should have attributes' do
    payment = Payment.create
    expect(payment.errors[:payable_id].present?).to eq(true)
    expect(payment.errors[:payable_type].present?).to eq(true)
    expect(payment.errors[:payment_type].present?).to eq(true)
  end
end
