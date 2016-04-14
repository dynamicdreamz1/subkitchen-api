class LikeValidator < ActiveModel::Validator
  def validate(record)
    if record.likeable_type == 'Product' && record.likeable.author_id == record.user_id
      record.errors.add(:user_id, 'cannot like own product')
    elsif record.likeable_type == 'User'
      if record.likeable.id == record.user_id
        record.errors.add(:user_id, 'cannot follow yourself')
      elsif !record.likeable.artist
        record.errors.add(:user_id, 'cannot be followed')
      elsif record.user_id.nil?
        record.errors.add(:user_id, 'has to be signed in to follow')
      end
    end
  end
end
