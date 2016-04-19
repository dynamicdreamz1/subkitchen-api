class TemplateVariant < ActiveRecord::Base
  belongs_to :color
  belongs_to :product_template

  attachment :template_color_image
end
