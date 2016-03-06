class CompanyValidator < ActiveModel::Validator
  def validate(record)
    unless record.user.artist
      record.errors.add(:user_id, "must be an artist ")
    end
  end
end