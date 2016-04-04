class ProductTemplateImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.send("#{attribute}_id_changed?")
      image = MiniMagick::Image.open(File.new(value.download.path))
      if image.height != 1024 || image.width != 1024
        record.errors.add(attribute, "#{attribute.to_s.humanize} must be 1024x1024")
      end
    end
  end
end