class CouponDateValidator < ActiveModel::Validator
  def validate(record)
    puts record.valid_from
    puts record.valid_until
    if record.valid_from > record.valid_until
      record.errors.add(:valid_until, 'invalid expiration date')
    end
  end
end
