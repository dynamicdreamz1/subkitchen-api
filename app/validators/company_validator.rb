class CompanyValidator < ActiveModel::Validator
  def validate(record)
    return unless record.user && !record.user.artist
    record.errors.add(:user_id, 'must be an artist')
  end
end
