class AddressValidator < ActiveModel::Validator
  def validate(record)
    if address_changed(record) && record.payment
      record.errors.add(:base, 'cannot update address fields when payment exist')
    end
  end

  private

  def address_changed(record)
    record.full_name_changed? || record.address_changed? || record.city_changed? || record.zip_changed? || record.region_changed? || record.country_changed?
  end
end