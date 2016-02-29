module Products
  class Api < Grape::API
    resources :products do

      helpers do
        def is_author?(current_user, product)
          product.author == current_user
        end

        def author?(current_user, product)
          if current_user
            current_user == product.author
          else
            false
          end
        end
      end

      desc 'return all products'
      get do
        page = params.page.to_i != 0? params.page : 1
        per_page = params.per_page.to_i != 0? params.per_page : 30
        products = Product.page(page).per(per_page)
        ProductListSerializer.new(products).as_json
      end

      desc 'return product by id'
      get ':id' do
        product = Product.find_by(id: params.id)
        if product
          ProductSerializer.new(product).as_json
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end

      desc 'create product'
      params do
        requires :name, type: String
        requires :product_template_id, type: Integer
        requires :description, type: String
        requires :image, type: File
        requires :published, type: Boolean
      end
      post do
        product = CreateProduct.new(current_user, params).call
        unless product.save
          status :unprocessable_entity
        end
        ProductSerializer.new(product).as_json
      end

      desc 'remove product'
      delete ':id' do
        product = Product.find_by(id: params.id)
        if product
          DeleteResource.new(product).call
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
        ProductSerializer.new(product).as_json
      end

      desc 'publish product'
      params do
        requires :product_id, type: Integer
      end
      post 'publish' do
        authenticate!
        product = Product.find_by(id: params.product_id)
        if product && is_author?(current_user, product)
          product.published = true
          unless product.save
            status :unprocessable_entity
          end
          ProductSerializer.new(product).as_json
        else
          error!({errors: {base: ['no product with given id or user is not an author']}}, 422)
        end
      end

      desc 'like product'
      params do
        requires :product_id, type: Integer
      end
      post 'like' do
        product = Product.find_by(id: params.product_id)
        if product
          if !author?(current_user, product)
            product.likes += 1
            product.save
          else
            error!({errors: {base: ['cannot like own product']}}, 422)
          end
        else
          error!({errors: {base: ['no product with given id']}}, 422)
        end
      end
    end
  end
end
