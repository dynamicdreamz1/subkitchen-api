class MaskValidator < ActiveModel::Validator
  def validate(record)
    if record.template_mask && record.template_mask_id_changed?
      mask = MiniMagick::Image.open(File.new(record.template_mask.download.path))
      if mask.height < 1024 || mask.width < 1024
        record.errors.add(:template_mask, 'Template mask too small. Must be at least 1024x1024')
      end
    end
  end
end