class TemplateVariant < ActiveRecord::Base
  belongs_to :color
  belongs_to :product_template
  has_many :order_items

  attachment :template_color_image

  validates :name, presence: true
  validates :color_id, presence: true
  validates :product_template_id, presence: true
end
