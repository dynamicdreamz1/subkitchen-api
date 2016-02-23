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
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 30
      end
      get do
        products = Product.page(params.page).per(params.per_page)
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
        optional :image, type: File
      end
      post do
        authenticate!
        image = ActionDispatch::Http::UploadedFile.new(params.image)
        product = Product.new(name: params.name,
                                 user_id: current_user.id,
                                 product_template_id: params.product_template_id,
                                 description: params.description,
                                 image: image)
        status :unprocessable_entity unless product.save
        product
      end

      desc 'remove product'
      delete ':id' do
        authenticate!
        product = Product.find_by(id: params.id, user_id: current_user.id)
        if product
          product.delete_product
        else
          status :unprocessable_entity
        end
      end
    end
  end
end
