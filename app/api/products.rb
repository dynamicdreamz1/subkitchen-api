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
        products = Product.page(page).per(per_page)
        {
          products: products.map{|p| ProductSerializer.serialize(p)},
          meta: {
            current_page: products.current_page,
            total_pages: products.total_pages
          }
        }
      end

      desc 'return product by id'
      get ':id' do
        {product: ProductSerializer.serialize(Product.find(params[:id]))}
      end

      desc 'create product'
      params do
        requires :name, type: String
        requires :product_template_id, type: Integer
        requires :description, type: String
        optional :image
      end
      post do
        authenticate!
        product = Product.new(name: params.name,
                                 user_id: current_user.id,
                                 product_template_id: params.product_template_id,
                                 description: params.description,
                                 image: params.image)
        if !product.save
        else
          status :unprocessable_entity
          product
        end
      end

      desc 'remove product'
      delete ':id' do
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
