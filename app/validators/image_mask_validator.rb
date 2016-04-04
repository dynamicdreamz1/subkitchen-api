class ImageMaskValidator < ActiveModel::Validator
  def validate(record)
    if record.template_image && record.template_image_id_changed?
      image = MiniMagick::Image.open(File.new(record.template_image.download.path))
      if image.height < 1024 || image.width < 1024
        record.errors.add(:template_image, 'Template image too small. Must be at least 1024x1024')
      end
    end
    if record.template_mask && record.template_mask_id_changed?
      mask = MiniMagick::Image.open(File.new(record.template_mask.download.path))
      if mask.height < 1024 || mask.width < 1024
        record.errors.add(:template_mask, 'Template mask too small. Must be at least 1024x1024')
      end
    end
  end
end