RSpec.describe NewsletterReceiver, type: :model do
  it 'should not create when is not unique' do
    create(:newsletter_receiver, email: 'test@example.com')
    expect { create(:newsletter_receiver, email: 'test@example.com') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should not create when email not present' do
    expect { create(:newsletter_receiver, email: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
