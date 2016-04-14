RSpec.describe EmailTemplate, type: :model do
  describe 'EmailKeysValidator' do
    context 'AccountEmailConfirmation' do
      it 'should not save without required key' do
        expect do
          create(:email_template, content: '', subject: '', name: 'AccountEmailConfirmation')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'should save with required key' do
        expect do
          create(:email_template, content: 'CONFIRMATION_URL', subject: '', name: 'AccountEmailConfirmation')
        end.to change(EmailTemplate, :count).by(1)
      end
    end

    context 'AccountResetPassword' do
      it 'should not save without required key' do
        expect do
          create(:email_template, content: '', subject: '', name: 'AccountResetPassword')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'should save with required key' do
        expect do
          create(:email_template, content: 'REMINDER_URL', subject: '', name: 'AccountResetPassword')
        end.to change(EmailTemplate, :count).by(1)
      end
    end

    context 'WaitingProductsNotifier' do
      it 'should not save without required key' do
        expect do
          create(:email_template, content: '', subject: '', name: 'WaitingProductsNotifier')
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'should save with required key' do
        expect do
          create(:email_template, content: 'PRODUCTS_LIST', subject: '', name: 'WaitingProductsNotifier')
        end.to change(EmailTemplate, :count).by(1)
      end
    end
  end
end
