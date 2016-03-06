class ChangeStatusIfArtist
  def after_create(record)
    set_status(record)
  end

  def after_update(record)
    set_status(record)
  end

  private

  def set_status(record)
    record.update_column(:status, 'pending') if record.artist
  end
end