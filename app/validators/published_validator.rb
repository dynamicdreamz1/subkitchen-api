class PublishedValidator < ActiveModel::Validator
  def validate(record)
    if record.published == true && (!record.author || !record.author.artist || !record.author.verified?)
      record.errors.add(:published, "can't be true when you're not an artist")
    end
  end
end