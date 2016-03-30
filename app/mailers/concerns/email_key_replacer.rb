module EmailKeyReplacer
  def replace_keys(content, values)
    self.class::KEYS.each do |key|
      send("replace_#{key.downcase}", content, values)
    end
  end
end