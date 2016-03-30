class Config < ActiveRecord::Base
  attachment :config_image, content_type: %w(image/jpeg image/png image/jpg)

  class << self
    def shipping_info
      where(name: 'shipping_info').first.value
    end

    def shipping_cost
      where(name: 'shipping_cost').first.value
    end

    def tax
      where(name: 'tax').first.value
    end

    def banner_img
      where(name: 'banner_img').first.config_image_url(:fill, 1920, 750, format: :png)
    end

    def promo_1_img
      where(name: 'promo_1_img').first.config_image_url(:fill, 400, 400, format: :png)
    end

    def promo_2_img
      where(name: 'promo_2_img').first.config_image_url(:fill, 400, 400, format: :png)
    end

    def promo_3_img
      where(name: 'promo_3_img').first.config_image_url(:fill, 400, 400, format: :png)
    end

    def banner_url
      where(name: 'banner_url').first.value
    end

    def promo_1_url
      where(name: 'promo_1_url').first.value
    end

    def promo_2_url
      where(name: 'promo_2_url').first.value
    end

    def promo_3_url
      where(name: 'promo_3_url').first.value
    end

    def designers
      where(name: 'designers').first.value
    end
  end
end

