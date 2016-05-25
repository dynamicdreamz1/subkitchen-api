class ImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.send("#{attribute}_id_changed?")
      image = MiniMagick::Image.open(File.new(value.download.path))
      if options[:range]
        validate_by_range(attribute, image, record)
      else
        validate_by_height_width(attribute, image, record)
      end
    end
  end

  def validate_by_height_width(attribute, image, record)
    return unless image_height_width_correct(image)
    record.errors.add(attribute, "#{attribute.to_s.humanize} must be #{options[:width]}x#{options[:height]}")
  end

  def image_height_width_correct(image)
    image.height != options[:height] || image.width != options[:width]
  end

  def validate_by_range(attribute, image, record)
    return if image_range_correct(image)
    record.errors.add(attribute, invalid_range_message(attribute))
  end

  def invalid_range_message(attribute)
    "#{attribute.to_s.humanize} must be at least #{options[:range].first}x#{options[:range].first}
                                  and at most #{options[:range].last}x#{options[:range].last}"
  end

  def image_range_correct(image)
    options[:range].include?(image.height) && options[:range].include?(image.width)
  end
end
