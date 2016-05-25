class LikeValidator < ActiveModel::Validator
  def validate(record)
    if record.likeable_type == 'Product'
      product_validations(record)
    elsif record.likeable_type == 'User'
      user_validations(record)
    end
  end

  private

  def product_validations(record)
    return unless record.likeable.author_id == record.user_id
    record.errors.add(:user_id, 'cannot like own product')
  end

  def user_validations(record)
    if user_follows_yourself(record)
      record.errors.add(:user_id, 'cannot follow yourself')
    elsif user_follows_user(record)
      record.errors.add(:user_id, 'cannot be followed')
    elsif user_not_signed_in(record)
      record.errors.add(:user_id, 'has to be signed in to follow')
    end
  end

  def user_not_signed_in(record)
    record.user_id.nil?
  end

  def user_follows_user(record)
    !record.likeable.artist
  end

  def user_follows_yourself(record)
    record.likeable.id == record.user_id
  end
end
