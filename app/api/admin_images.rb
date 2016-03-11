module AdminImages
  class Api < Grape::API

    desc 'admin images'
    get 'admin_images' do
     {
         banner_img: Config.banner_img,
         promo_1_img: Config.promo_1_img,
         promo_2_img: Config.promo_2_img,
         promo_3_img: Config.promo_3_img,
         banner_url: Config.banner_url,
         promo_1_url: Config.promo_1_url,
         promo_2_url: Config.promo_2_url,
         promo_3_url: Config.promo_3_url
     }
    end
  end
end