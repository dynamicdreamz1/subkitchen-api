module EmailKeyReplacer
  def self.included(klass)
    klass::KEYS.keys.each do |key|
      define_method("replace_#{key.downcase}") do |content, values|
        content.gsub!(key, values[key.downcase])
      end
    end
  end

  def replace_keys(content, values)
    self.class::KEYS.keys.each do |key|
      send("replace_#{key.downcase}", content, values)
    end
  end
end
