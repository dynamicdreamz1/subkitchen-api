class EmailKeysValidator < ActiveModel::Validator
  def validate(record)
    case record.name
    when 'AccountEmailConfirmation'
      check_if_content_contains(record, 'CONFIRMATION_URL')
    when 'AccountResetPassword'
      check_if_content_contains(record, 'REMINDER_URL')
    when 'WaitingProductsNotifier'
      check_if_content_contains(record, 'PRODUCTS_LIST')
    else return true
    end
  end

  def check_if_content_contains(record, phrase)
    return if record.content.include?(phrase)
    record.errors.add(:content, "must contain #{phrase}")
  end
end
