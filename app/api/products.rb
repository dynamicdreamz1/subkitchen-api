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
      desc 'return all products'
      get '' do
        page = params[:page].to_i != 0? params[:page] : 1
        per_page = params[:per_page].to_i != 0? params[:per_page] : 30
        Product.page(page).per(per_page)
      end

      desc 'return product by id'
      get ':id' do
        product = Product.find(params[:id])
        if product
          ProductSerializer.serialize(product)
        else
          status :unprocessable_entity
        end
      end

      desc 'create product'
      params do
        requires :name, type: String
      end
      post 'create' do
        authenticate!
        product = Product.create(name: params.name, user_id: current_user.id)
        if product
          product
        else
          status :unprocessable_entity
        end
      end

      desc 'remove product'
      params do
        requires :product_id, type: Integer
      end
      delete 'remove' do
        authenticate!
        product = Product.find_by(id: params.product_id, user_id: current_user.id)
        if product
          product.destroy
        else
          status :unprocessable_entity
        end
      end
    end
  end
end
