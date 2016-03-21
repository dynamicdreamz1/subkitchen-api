class Config < ActiveRecord::Base
  scope :shipping_info, lambda { where(name: 'shipping_info').first.value }
  scope :shipping_cost, lambda { where(name: 'shipping_cost').first.value }
  scope :tax, lambda { where(name: 'tax').first.value }
  scope :banner_img, lambda { where(name: 'banner_img').first.config_image_url(:fill, 1920, 750, format: :png) }
  scope :promo_1_img, lambda { where(name: 'promo_1_img').first.config_image_url(:fill, 400, 400, format: :png) }
  scope :promo_2_img, lambda { where(name: 'promo_2_img').first.config_image_url(:fill, 400, 400, format: :png) }
  scope :promo_3_img, lambda { where(name: 'promo_3_img').first.config_image_url(:fill, 400, 400, format: :png) }
  scope :banner_url, lambda { where(name: 'banner_url').first.value }
  scope :promo_1_url, lambda { where(name: 'promo_1_url').first.value }
  scope :promo_2_url, lambda { where(name: 'promo_2_url').first.value }
  scope :promo_3_url, lambda { where(name: 'promo_3_url').first.value }
  scope :designers, lambda { where(name: 'designers').first.value }


  attachment :config_image, content_type: %w(image/jpeg image/png image/jpg)
end

