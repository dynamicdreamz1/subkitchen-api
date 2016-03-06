class LikeValidator < ActiveModel::Validator
  def validate(record)
    if record.likeable.author_id == record.user_id
      record.errors.add(:user_id, 'cannot like own product')
    end
  end
end