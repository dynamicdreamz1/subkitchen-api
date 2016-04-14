class EmailKeysValidator < ActiveModel::Validator
  def validate(record)
    case record.name
    when 'AccountEmailConfirmation'
      unless record.content.include?('CONFIRMATION_URL')
        record.errors.add(:content, 'must contain CONFIRMATION_URL')
      end
    when 'AccountResetPassword'
      unless record.content.include?('REMINDER_URL')
        record.errors.add(:content, 'must contain REMINDER_URL')
      end
    when 'WaitingProductsNotifier'
      unless record.content.include?('PRODUCTS_LIST')
        record.errors.add(:content, 'must contain PRODUCTS_LIST')
      end
    else return true
    end
  end
end
