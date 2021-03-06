class CouponDateValidator < ActiveModel::Validator
  def validate(record)
    return unless record.valid_from > record.valid_until
    record.errors.add(:valid_until, 'invalid expiration date')
  end
end
