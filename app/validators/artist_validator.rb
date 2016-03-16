class ArtistValidator < ActiveModel::Validator
  def validate(record)
    if record.artist && !record.email_confirmed
      record.errors.add(:artists, 'email must be confirmed')
    end
  end
end