class ImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.send("#{attribute}_id_changed?")
      image = MiniMagick::Image.open(File.new(value.download.path))
      if options[:range]
        unless options[:range] === image.height && options[:range] === image.width
          record.errors.add(attribute, "#{attribute.to_s.humanize} must be at least #{options[:range].first}x#{options[:range].first} and at most #{options[:range].last}x#{options[:range].last}")
        end
      else
        if image.height != options[:height] || image.width != options[:width]
          record.errors.add(attribute, "#{attribute.to_s.humanize} must be #{options[:width]}x#{options[:height]}")
        end
      end
    end
  end
end