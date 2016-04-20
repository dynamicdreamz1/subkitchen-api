class Color < ActiveRecord::Base
  has_many :template_variants
  attachment :color_image

  validates :name, presence: true
  validates :color_value, presence: true
end
