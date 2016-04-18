class Color < ActiveRecord::Base
  has_many :template_variants
  attachment :color_image
end
