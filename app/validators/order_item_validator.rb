class OrderItemValidator < ActiveModel::Validator
  def validate(record)
    if record.order && record.order.payment
      record.errors.add(:base, 'cannot save item when payment exist')
    end
  end
end
