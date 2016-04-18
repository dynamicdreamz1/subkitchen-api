module AppConfig
  class Api < Grape::API
    desc 'get config'
    get 'config' do
      { banner_img:  "#{Figaro.env.app_host}#{Config.banner_img}",
        promo_1_img: "#{Figaro.env.app_host}#{Config.promo_1_img}",
        promo_2_img: "#{Figaro.env.app_host}#{Config.promo_2_img}",
        promo_3_img: "#{Figaro.env.app_host}#{Config.promo_3_img}",
        banner_url:  Config.banner_url,
        promo_1_url: Config.promo_1_url,
        promo_2_url: Config.promo_2_url,
        promo_3_url: Config.promo_3_url }
    end

    desc 'get themes'
    get 'themes' do
      { themes: Config.themes.split(',').map(&:strip).compact.reject(&:blank?) }
    end
  end
end
