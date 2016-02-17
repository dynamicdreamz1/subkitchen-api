module Products
  class Api < Grape::API
    get 'promo' do
      %w(http://lorempixel.com/400/400/
      http://lorempixel.com/1920/800/)
    end
    get 'tshirts' do
      %w(http://lorempixel.com/300/300/)
    end
    resources :products do
      desc 'Return all products'
      get '' do
        page = params[:page].to_i != 0? params[:page] : 1
        per_page = params[:per_page].to_i != 0? params[:per_page] : 30
        Product.page(page).per(per_page)
      end

      desc 'Return product by id'
      get ':id' do
        Product.find(params[:id])
      end
    end
  end
end
