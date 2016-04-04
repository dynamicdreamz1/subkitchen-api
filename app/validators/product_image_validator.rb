class ProductImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.send("#{attribute}_id_changed?")
      image = MiniMagick::Image.open(File.new(value.download.path))
      if image.height < 1024 || image.width < 1024
        record.errors.add(attribute, "#{attribute.to_s.humanize} must be at least 1024x1024")
      elsif image.height > 5000 || image.width > 5000
        record.errors.add(attribute, "#{attribute.to_s.humanize} must be at most 5000x5000")
      end
    end
  end
end