class TemplateVariant < ActiveRecord::Base
  belongs_to :color
  belongs_to :product_template
  has_many :products

  attachment :template_color_image
end
