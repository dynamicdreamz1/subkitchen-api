class UserImagesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, image_url)
    if image_url && record.send("#{attribute}_changed?")
      if options[:range]
        validate_by_range(attribute, image_url, record)
      else
        validate_by_height_width(attribute, image_url, record)
      end
    end
  end

  def validate_by_height_width(attribute, image_url, record)
    return if image_height_width_correct(image_url)
    record.errors.add(attribute, "#{attribute.to_s.humanize} must be #{options[:width]}x#{options[:height]}")
  end

  def image_height_width_correct(image_url)
		dimensions = FastImage.size(image_url)
    dimensions[0] == options[:width] && dimensions[1] == options[:height]
  end

  def validate_by_range(attribute, image_url, record)
    return if image_range_correct(image_url)
    record.errors.add(attribute, invalid_range_message(attribute))
  end

  def invalid_range_message(attribute)
    "#{attribute.to_s.humanize} must be at least #{options[:range].first}x#{options[:range].first}
                                  and at most #{options[:range].last}x#{options[:range].last}"
  end

  def image_range_correct(image_url)
		dimensions = FastImage.size(image_url)
    options[:range].include?(dimensions[0]) && options[:range].include?(dimensions[1])
  end
end
