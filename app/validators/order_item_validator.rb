class OrderItemValidator < ActiveModel::Validator
  def validate(record)
    return unless record.order && record.order.payment
    record.errors.add(:base, 'cannot save item when payment exist')
  end
end
